################################################################################
#  Item-Dismantling script    v. 2.4.0                                         #
#                                  by Tidloc         (Oct-12-15)               #
#==============================================================================#
#  Feel free to use it in your own RPG-Maker game.                             #
#  But please give me credits for this hell of work ^_^                        #
#------------------------------------------------------------------------------#
#  for using this script write the script-command                              #
#     Tidloc_Dismantle.call                                                    #
#------------------------------------------------------------------------------#
#  to setup an item to be dismantleable, you need these notetags:              #
#    <dismantle> .... makes an item available to dismantle                     #
#                                                                              #
#    <Res1=a,b,c> ...                                                          #
#    <Res2=a,b,c> ... a=0 for item, a=1 for weapon, a=2 for armor              #
#    <Res3=a,b,c> ... b is the database-id of the reesulting item              #
#    <Res4=a,b,c> ... c is the amount that the dismantle will yield            #
#    and so on... theoretical maximum is 100 xD                                #
#  If no ressources are setup, the item will simply vanish upon dismantling!   #
#------------------------------------------------------------------------------#
# you can change the windowcolor, tone, opacity and background of this script, #
# by editing the following constants:                                          #
#    Windowskin   = "Name of the windowskin in systemfolder"                   #
#    Windowtone   = [a,b,c]                                                    #
#    Opacity      = 255                                                        #
#    Background   = "Name of picture in the picturefolder"                     #
#    Dismantle_SE = [s,v,p]                                                    #
#    Confirmation = true if a confirmation window shall be shown upon choosing #
#    Info_Window  = true if a window shal be shown at all time to display the  #
#                   outcome of a dismantling                                   #
# where a,b and c are the RPG-values.                                          #
# s is the SE-name within quotation marks or nil, v is the volume in percent   #
# and p is the pitch in percent.                                               #
#==============================================================================#
#   If any questions appear feel free to contact me!                           #
#                                                tidloc@gmx.at                 #
#                                                149436915 (ICQ)               #
################################################################################

$imported = {} if $imported.nil?
$imported["Tidloc-Dismantle"] = [2,4,0]
$needed   = [] if $needed.nil?
$needed.push ["Tidloc-Header",[2,11,0],true,"Tidloc-Dismantle"]
$needed.push ["HTML-tagging", [1, 5,0],true,"Tidloc-Dismantle"]

module Tidloc
######### if you don't want to call this script via a Key on the map, simply
######### leave nil, or else put the desired Key here
  Keys = {} if Keys.nil?
  Keys["Dismantle"] = nil
  Menu = {} if Menu.nil?
  Menu["Dismantle"] = nil
  
  module Dismantle
    Windowskin   = nil
    Windowtone   = nil
    Opacity      = 255
    Background   = nil
    Back_BGS     = nil
    
    Dismantle_SE = ["break",55,70]
    Confirmation = false
    Info_Window  = true
    
    Notetags = [/<dismantle>/i,
                ["<Res","=([0-9]+),([0-9]+),([0-9]+)>"],
                ]
  end
  
  module Vocabs;class<<self
    def Dismantle(code,lang)
      if    lang == "ger"
        case code
        when "Name"    ; return "Zerlegen"
        when "Recieve" ; return "Erhaltene Gegenstände:"
        when "req"     ; return "| zerlegen?"
        when "con"     ; return "ENTER = OK        ESC = abbr."
        when "info"    ; return "Zerlegung:"
        end
      elsif lang == "eng"
        case code
        when "Name"    ; return "Dismantling"
        when "Recieve" ; return "Items received:"
        when "req"     ; return "Dismantle |?"
        when "con"     ; return "ENTER = OK        ESC = cancel"
        when "info"    ; return "Dismantling:"
        end
      end
    end
  end;end
end

################################################################################
################################################################################
################################################################################

module Tidloc
  module Dismantle
    class Window_Help_2 < Window_Help
      def initialize
        super
        self.windowskin = Cache.system(Tidloc::Dismantle::Windowskin) if Tidloc::Dismantle::Windowskin
        t = Tidloc::Dismantle::Windowtone
        self.tone.set(t[0],t[1],t[2],128) if t
        self.opacity = Tidloc::Dismantle::Opacity
      end
      def update_tone
        if Tidloc::Dismantle::Windowtone
          t = Tidloc::Dismantle::Windowtone
          self.tone.set(t[0],t[1],t[2],128)
        else
          super
        end
      end
    end
    class Window_Item_2 < Window_ItemList
      def initialize
        w = Tidloc::Dismantle::Info_Window ? Graphics.width/2 : Graphics.width
        super(0,72, w, Graphics.height-72)
        self.windowskin = Cache.system(Tidloc::Dismantle::Windowskin) if Tidloc::Dismantle::Windowskin
        t = Tidloc::Dismantle::Windowtone
        self.tone.set(t[0],t[1],t[2],128) if t
        self.opacity = Tidloc::Dismantle::Opacity
      end
      def update_tone
        if Tidloc::Dismantle::Windowtone
          t = Tidloc::Dismantle::Windowtone
          self.tone.set(t[0],t[1],t[2],128)
        else
          super
        end
      end
      
      alias wo_tidloc_dimantle_make_item_list make_item_list
      def make_item_list
        @data = []
        if $imported["Tidloc-CustomEquip"]
          for i in $game_party.all_items
            @data.push i if include?(i)
          end
        else
          wo_tidloc_dimantle_make_item_list
        end
      end
      def include?(item)
        return false if item.nil?
        return false unless item.note =~ Tidloc::Dismantle::Notetags[0]
        return true  if item.is_a?(RPG::Item)
        return true  if item.is_a?(RPG::Weapon)
        return true  if item.is_a?(RPG::Armor)
        return true  if $imported["Tidloc-CustomEquip"] && (item.is_a?(Tidloc::CustomEquip::Weapon) || item.is_a?(Tidloc::CustomEquip::Armor))&& item.inv
        return false
      end
      def enable?(item)
        true
      end
      def refresh
        make_item_list
        super
      end
    end
    class Window_Base_2 < Window_Base
      def initialize(x, y, width, height)
        super(x,y,width,height)
        self.windowskin = Cache.system(Tidloc::Dismantle::Windowskin) if Tidloc::Dismantle::Windowskin
        t = Tidloc::Dismantle::Windowtone
        self.tone.set(t[0],t[1],t[2],128) if t
      end
      def update_tone
        if Tidloc::Dismantle::Windowtone
          t = Tidloc::Dismantle::Windowtone
          self.tone.set(t[0],t[1],t[2],128)
        else
          super
        end
      end
    end
    class Window_Confirm < Window_Base
      attr_accessor :text
      def initialize
        self.text = ""
        super(Graphics.width/2-150,Graphics.height/2-45,300,90)
      end
      def update
        super
        self.contents.clear
        draw_text 0, 0,260,30,self.text,1
        draw_text 0,30,260,30,Tidloc::Vocabs.Dismantle("con",$tidloc_language),1
      end
    end
  end
end

class Tidloc_Dismantle < Scene_Base
  def initialize
    @classtemp  = 1
  end
  def start
    super
#~     if Tidloc::Item_Categories
#~       @classtemp = 0
#~       @class_window = Window_Class_Display.new(0,64,640)
#~     end
    
    @message_window = Tidloc::Dismantle::Window_Base_2.new 144,160,320,186
    @message_window.deactivate.hide.z = 1000
    if Tidloc::Dismantle::Info_Window
      @info_window  = Tidloc::Dismantle::Window_Base_2.new Graphics.width/2,72,Graphics.width/2,Graphics.height-72
      @info_window.opacity = Tidloc::Dismantle::Opacity
    end
    
    @help_window    = Tidloc::Dismantle::Window_Help_2.new
    @item_window    = Tidloc::Dismantle::Window_Item_2.new
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.set_handler(:change, method(:on_item_change))
    @item_window.help_window = @help_window
    @item_window.activate.refresh
    @item_window.index = 0 if @item_window.item_max > 0
    @confirm_window = Tidloc::Dismantle::Window_Confirm.new
    @confirm_window.hide.deactivate
    
    create_background if Tidloc::Dismantle::Background
    
    autoplay
    on_item_change
  end
  
  def autoplay
    return false if Tidloc::Dismantle::Back_BGS.nil?
    RPG::BGS.new(Tidloc::Dismantle::Back_BGS,50,100).play
  end
  
  def create_background
    @background_window   = Window_Base.new -12,-36,Graphics.width+32,Graphics.height+64
    @background_window.z = 0
    @background_window.opacity = 0
    @background_window.draw_html 0,0,Graphics.width,Graphics.height,
    "<img=#{Tidloc::Dismantle::Background}>"
  end
  
  alias wo_tidloc_dismantle_update_all_windows update_all_windows
  def update_all_windows
    if @message_window.active
      if Input.trigger?(:B) || Input.trigger?(:C)
        @message_window.deactivate.hide
        @item_window.activate
        Sound.play_ok
        return
      end
    elsif @confirm_window.active
      text = Tidloc::Vocabs.Dismantle("req",$tidloc_language)
      text = text.gsub("|") {@item_window.item.name}
      @confirm_window.text = text
      if    Input.trigger?(:B)
        @confirm_window.hide.deactivate
        @item_window.activate
        return
      elsif Input.trigger?(:C)
        on_confirm_ok
        @confirm_window.hide.deactivate
        return
      end
    end
    wo_tidloc_dismantle_update_all_windows
  end
  
  def on_item_ok
    if @item_window.item
      if Tidloc::Dismantle::Confirmation
        @confirm_window.show.activate
      else
        on_confirm_ok
      end
    else
      return_scene
    end
  end
  def on_item_change
    @info_window.contents.clear
    return unless Tidloc::Dismantle::Info_Window && @item_window.item
    @info_window.draw_html 0,20,@info_window.contents.width,32,
         Tidloc::Vocabs.Dismantle("info",$tidloc_language)
    for i in 1..100
      if @item_window.item.note =~ /#{Tidloc::Dismantle::Notetags[1][0]}#{i}#{Tidloc::Dismantle::Notetags[1][1]}/i
        cla = $1.to_i
        id  = $2.to_i
        amo = $3.to_i
        text  = amo.to_s + "ˣ "
        case cla
        when 0
          text += "<icon=#{$data_items[id].icon_index}>"
          text += $data_items[id].name
        when 1
          text += "<icon=#{$data_weapons[id].icon_index}>"
          text += $data_weapons[id].name
        when 2
          text += "<icon=#{$data_armors[id].icon_index}>"
          text += $data_armors[id].name
        end
        @info_window.draw_html(10,20+32*i,@info_window.contents.width-15,32,text)
      else
        return
      end
    end
  end
  def on_confirm_ok
    item = @item_window.item
    if item.is_a?(RPG::Item)
      $game_party.gain_item($data_items[item.id],-1)
    elsif item.is_a?(RPG::Weapon)
      $game_party.gain_item($data_weapons[item.id],-1)
    elsif item.is_a?(RPG::Armor)
      $game_party.gain_item($data_armors[item.id],-1)
    elsif $imported["Tidloc-CustomEquip"] && item.is_a?(Tidloc::CustomEquip::Weapon)
      $game_party.lose_item_for_all_time(item)
    elsif $imported["Tidloc-CustomEquip"] && item.is_a?(Tidloc::CustomEquip::Armor)
      $game_party.lose_item_for_all_time(item)
    else
      Sound.play_buzzer
      @item_window.activate
      return
    end
    if Tidloc::Dismantle::Dismantle_SE && Tidloc::Dismantle::Dismantle_SE[0]
      RPG::SE.new(*Tidloc::Dismantle::Dismantle_SE).play
    else
      Sound.play_ok
    end
    @item_window.refresh
    on_item_change
    @message_window.contents = Bitmap.new(288, 154)
    @message_window.contents.draw_text(0,0,288,32,Tidloc::Vocabs.Dismantle("Recieve",$tidloc_language))
    @message_window.activate.show
    for i in 1..100
      if item.note =~ /#{Tidloc::Dismantle::Notetags[1][0]}#{i}#{Tidloc::Dismantle::Notetags[1][1]}/i
        cla = $1.to_i
        id  = $2.to_i
        amo = $3.to_i
        text  = amo.to_s + "ˣ "
        case cla
        when 0
          text += "<icon=#{$data_items[id].icon_index}>"
          text += $data_items[id].name
          $game_party.gain_item($data_items[id],amo)
        when 1
          text += "<icon=#{$data_weapons[id].icon_index}>"
          text += $data_weapons[id].name
          $game_party.gain_item($data_weapons[id],amo)
        when 2
          text += "<icon=#{$data_armors[id].icon_index}>"
          text += $data_armors[id].name
          $game_party.gain_item($data_armors[id],amo)
        end
        @message_window.contents.draw_html(0,32*i,288,32,text)
      else
        @item_window.refresh
        return
      end
    end
    @item_window.refresh
  end
  def pre_terminate
    RPG::BGS.stop
  end
  
  def Tidloc_Dismantle.call
    SceneManager.call(Tidloc_Dismantle)
  end
end