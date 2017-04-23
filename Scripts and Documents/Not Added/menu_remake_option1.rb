#==============================================================================
# KEY ITEM ONLY MENU V 2.0
#     Created by: Uriel Everos / mikkoman123
#==============================================================================
# This Script Features the Following:
# † Opening the menu, opens up the Key Item list
# † Key Item Selection Repositioning
# † Customizable
#==============================================================================
# ☩ CUSTOMIZATION
#==============================================================================

module KIOM
  module CONFIG
    
    # There are three positions:
    # † Item Description below list = 1 ;default
    # † Item Description above list = 2
    # † Use Custom Settings = 0
    ITEM_MENU_POSITION = 1
    
    # There are three positions:
    # † Key Item Select appears at the bottom of screen= 1 ;default
    # † Key Item Select appears at the top of screen = 2
    # † Use Custom Settings = 0
    KEY_ITEM_MENU_POSITION = 1
    
    # Select Key Items directly from the menu:
    # † true/false ;default = true
    # † A key on the keyboard (X Button) will have to be used unless changed
    # Set Variable for Key Item
    SELECTKEYONMENU = true
    SELECTKEYONMENU_MESSAGE = true # Confirmation message will pop-up if true
    SELECTKEYONMENU_TEXT = "Item Set" # Text that will be shown if
                                      # SELECTKEYONMENU_MESSAGE = true
    KEYITEMVARIABLE = 1
    
    # † A key on the keyboard (:X) ;default
    # † S key on the keyboard (:Y)
    # † D key on the keyboard (:Z)
    KEYBUTTON = :X
    
    # Placement of windows Horizontally and Width of each
    ITEM_XPOS = 67 # default = 67
    ITEM_WIDTH = Graphics.height # default = Graphics.height
    HELP_XPOS = 67 # default = 67
    HELP_WIDTH = Graphics.height # default = Graphics.height
    KEY_XPOS = 67 # default = 67
    KEY_WIDTH = Graphics.height # default = Graphics.height
    
    case ITEM_MENU_POSITION
    when 0 then
    CUSTOM_ITEM_YPOS = 0 # Position of Item list on Y axis
    CUSTOM_ITEM_HEIGHT = 0 # Height of Item list
    end
 
    case KEY_ITEM_MENU_POSITION
    when 0 then
    CUSTOM_KEY_ITEM_MENU_POSITION = 0 # Position of Key Item Select on Y axis
    end
  end
end

#==============================================================================
# ☩ Editing beyond this point will lead to headache and death.
#==============================================================================

#==============================================================================
# ☩ Repositions Item List
#==============================================================================
class Scene_Menu < Scene_MenuBase
include KIOM::CONFIG

  def create_item_window
    create_help_window
    case ITEM_MENU_POSITION
      when 1 then
      thisheight = Graphics.height - @help_window.height
      wy = 0
      when 2 then
      wy = @help_window.height
      thisheight = Graphics.height - wy
      when 0 then
      wy = CUSTOM_ITEM_YPOS
      thisheight = CUSTOM_ITEM_HEIGHT
    end
    @item_window = Window_ItemList.new(ITEM_XPOS, wy, ITEM_WIDTH, thisheight)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:ok,     method(:on_item_ok))
    @item_window.set_handler(KEYBUTTON,     method(:on_item_ok2))
    @item_window.set_handler(:cancel, method(:return_scene))
    @item_window.category = :key_item
    @item_window.select_last
    @item_window.activate
  end
 
  def on_item_ok
    $game_party.last_item.object = item; determine_item
  end
  def on_item_ok2
    if SELECTKEYONMENU
      result = item ? item.id : 0
      $game_variables[KEYITEMVARIABLE] = result
      SceneManager.goto(Scene_Map)
      if SELECTKEYONMENU_MESSAGE
        $game_message.position = 1
        $game_message.background = 1
        $game_message.add(SELECTKEYONMENU_TEXT)
      end
    end
  end
 
  def keypress?
    return Input.press?(KEYBUTTON)
  end
 
  def on_item_cancel
    @item_window.unselect; @category_window.activate
  end
  def determine_item
    if item.for_friend?
      show_sub_window(@actor_window); @actor_window.select_for_item(item)
    else
      use_item; activate_item_window;
    end
  end
  def activate_item_window
    @item_window.refresh; @item_window.activate
  end
  def use_item
    play_se_for_item; user.use_item(item); check_common_event; check_gameover
    @item_window.redraw_current_item
  end
 
  def check_common_event;
    SceneManager.goto(Scene_Map) if $game_temp.common_event_reserved?
  end
 
  def start; super; create_item_window; end
  def play_se_for_item; end
  def user; $game_party.movable_members.max_by {|member| member.pha }; end
  def item; @item_window.item; end
end
 
#==============================================================================
# ☩ Repositions Help Window
#==============================================================================
class Window_Help < Window_Base
  include KIOM::CONFIG
  def initialize(line_number = 2)
    height = Graphics.height - fitting_height(line_number)
    case ITEM_MENU_POSITION
      when 1 then; super(HELP_XPOS, height, HELP_WIDTH, fitting_height(line_number))
      when 2 then; super(HELP_XPOS, 0, HELP_WIDTH, fitting_height(line_number))  
    end
  end
end

#==============================================================================
# ☩ Repositions Key Item Select
#==============================================================================
class Window_KeyItem < Window_ItemList
  include KIOM::CONFIG
  def initialize(message_window)
    @message_window = message_window
    super(KEY_XPOS, 0, KEY_WIDTH, fitting_height(4))
    self.openness = 0
    deactivate
    set_handler(:ok,     method(:on_ok))
    set_handler(:cancel, method(:on_cancel))
  end
  def update_placement
    if @message_window.y >= Graphics.height / 2
      case KEY_ITEM_MENU_POSITION
        when 1 then self.y = Graphics.height - fitting_height(4)
        when 2 then self.y = 0
        when 0 then self.y = CUSTOM_KEY_ITEM_MENU_POSITION
      end
    else
      self.y = Graphics.height - height
    end
  end
end

#==============================================================================
# ☩ Removes Item Numbers
#==============================================================================
class Window_ItemList < Window_Selectable
  include KIOM::CONFIG
  def draw_item_number(rect, item); end
    
  def ok_enabled2?
    handle?(KEYBUTTON)
  end
 
  def call_ok_handler2
    call_handler(KEYBUTTON)
  end
 
  alias process_handling_alias process_handling
  def process_handling
    return unless open? && active
    return process_ok2       if ok_enabled2?        && Input.trigger?(KEYBUTTON)
    process_handling_alias
  end
 
  def process_ok2
    if current_item_enabled?
      Sound.play_ok
      Input.update
      deactivate
      call_ok_handler2
    else
      Sound.play_buzzer
    end
  end
end

#==============================================================================
# ☩ End of script
#==============================================================================