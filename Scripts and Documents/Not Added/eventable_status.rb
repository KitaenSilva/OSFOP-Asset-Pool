#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#             Story-Entwined Status Screen
#             Version: 1.0
#             Authors: DiamondandPlatinum3
#             Date: December 8, 2012
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Description:
#
#    This script overhals the default status screen and replaces it with a fully
#    customisable system that allows you to modify actor descriptions, names, 
#    font colours, side images and background textures to be used to show how
#    much devleopment your characters have gone through throughout your game.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#------------------------------------------------------------------------------
#  Instructions:
#  
#     In the editable region below, you can modify default values for font colours
#     and set up textures for your already playable characters. Textures are individual
#     to each character whilst font will be the same for all characters unless you
#     specify individual colours (as explained below).
#
#
#     In order to get specific font colours per character, you will need to used 
#     the following script call in an event
#
#       status_screen_modify_font_gauge_options( actor, option, red, green, blue )
#
#     - Where 'actor' can either be the name of the actor you wish to modify like "Ralph" (The 
#     name that is specified in the database, NOT in this script), or the ID of that actor.
#     - 'option' is to be replaced with one of the font identifiers in the editable, pretty
#     much just copy-paste them in quotation marks "NameFontColour".
#     - Red, Green, Blue are just replaced by the RGB values for colours, you can find 
#     these on most paint associated software like Photoshop and Paint.net, or even online.
#
#
#     There are more methods to use beside changing just the font per character.
#     You can also modify Names and descriptions (only for the status screen, doesn't modify 
#     these in the database) and add or remove textures as you wish.
#     Use the Following Script Calls:
#
#         status_screen_modify_actor_full_name( actor, sName )
#         status_screen_add_background_image( actor, sImageName, width, height )
#         status_screen_remove_background_image( actor, sImageName )
#         status_screen_change_character_image( actor, sImageName, width, height )
#         status_screen_change_character_description( actor, sDescription )
#
#
#     'actor' means the same as above, replace the other things with exactly what
#     they say they want, width & height for images is asking you what width and 
#     height you want to draw the image with, NOT what the width and height of the 
#     actual image is!
#     Just remember that if you are passing in an argument with an 's' in front of it,
#     that means that you need to put your argument in quotation marks, the same is true if
#     you want to pass in 'actor' by their name rather than their ID.
#
#
#     Those script calls are all you really need to worry about, you'll learn quicker by
#     just messing around with it, so try it out.
#
#
#     An Example Screenshot can be seen here:
#     http://img4host.net/upload/0719500050c23a582f923.png
#
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
($diamondandplatinum3_scripts ||= {})[:StoryEntwinedStatusScreen] = true

module DiamondandPlatinum3
  module StatusScreenOptions
    #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    #                                                        -= 
    #                 Editable Region        ////            ==
    #                                                        =-
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    ShowActorNickname         = true  # Do you wish the Actor's nickname to be shown?
    ShowHLAfterName           = true  # Do you want to show a Horizontal Line just below your characters name?
    SecondsUntilSwitchBGImage = 8     # How Many Seconds Until the Background is swapped?
    #=======================================================================
    # * Font/Gauge Colours, modify the RGB (Red, Green, Blue) values
    # Use an online RGB colour wheel or other to get RGB values for colours
    #=======================================================================
    NameFontColour            = [ 255, 150, 0   ]
    ClassLabelFontColour      = [ 100, 100, 241 ]
    ClassFontColour           = [ 100, 100, 241 ]
    NicknameLabelFontColour   = [ 214, 50,  100 ]
    NicknameFontColour        = [ 214, 50,  100 ]
    LevelLabelFontColour      = [ 58,  255, 225 ]
    LevelFontColour           = [ 58,  255, 225 ]
    StatusLabelFontColour     = [ 100, 100, 100 ]
    EquipmentLabelFontColour  = [ 255, 248, 45  ]
    EquipmentFontColour       = [ 255, 248, 45  ]
    ParameterLabelFontColour  = [ 30,  255, 30  ]
    ParameterFontColour       = [ 100, 200, 30  ]
    HP_GaugeColour            = [ 255, 30,  30  ]
    MP_GaugeColour            = [ 30,  30,  255 ]
    EXP_GaugeColour           = [ 30,  255, 30  ]
    DescriptionFontColour     = [ 255, 30,  30  ]
    #=======================================================================
    # * Character Display Name: this exists so that your character can have 
    #   a full name displayed in the status screen. If your character doesn't 
    #   have a full name, just enter their first name
    #=======================================================================
    #-----------------------------------------------------------------------
    CharacterDisplayName = [ # <= Do not Touch this line
    #-----------------------------------------------------------------------
    "Rita ???",          # Full Name of Actor 1
    "Emily ???",         # Full Name of Actor 2
                         # Copy-paste above to add more
    #=======================================================================
    # * Background Picture: in this section you write the filename, then the
    #   width you want the image, then the height you want the image. This is
    #   written in an array format:
    #   [ "Filename", Width, Height, 
    #     "Filename", Width, Height,
    #       *Repeat
    #   when you are finished adding all images for that character, you move 
    #   on to the next character by adding '],'
    #=======================================================================
    #-----------------------------------------------------------------------
    ]; BackgroundPictures = [ # <= Do not Touch this line
    #-----------------------------------------------------------------------
    [ "Rita12", 544, 416, 
      "Rita18", 294, 416, 
      "Rita19", 286, 416, 
      "Rita17", 224, 416 ],   # Background Images for Actor 1
      
    [ "Emily2", 276, 416, 
      "Emily4", 544, 416, ],  # Background Images for Actor 2
      
    [ "Blah", 544, 416 ],     # Background Images for Actor 3
    
    [],                       # No Background Images for Actor 4
    
    #=======================================================================
    # * Character Image: in this section you write the filename, width & 
    #   height of the image you want to have displayed when this character is
    #   selected, it's the same as the above except you are limited to only
    #   one image per actor.
    #=======================================================================
    #-----------------------------------------------------------------------
    ]; CharacterImage = [ # <= Do not Touch this line
    #-----------------------------------------------------------------------
    [ "Rita_Sketch", 161, 416 ],     # Character Image for Actor 1
    [ "Emily3", 121, 416 ],          # Character Image for Actor 2
    
    #-----------------------------------------------------------------------
    ] # <= Do not Touch this line
    #-----------------------------------------------------------------------
  end # Of Editable Region
  #-------------------------------------------------------------------------
end
















#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  This window displays full status specs on the status screen.
#==============================================================================

class Window_Status < Window_Selectable
  include DiamondandPlatinum3::StatusScreenOptions
  #--------------------------------------------------------------------------
  # * Overwritten Method: Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
    # New Instance Variables
    @x = @y = 0; @w = 112; @h = line_height
    @description_helpwindow = Window_Help.new()
    @description_helpwindow.y = Graphics.height - @description_helpwindow.height
    
    @actor_BackgroundPictureSprites = []
    @actor_CharacterImage = []
    @currently_selected_actor_id = actor.id
    
    # Iterate Through The Background Images 2D Array
    $game_system.dp3_status_screen_actor_backgroundimages_array.each do |actorBP_Array|
      root_index = @actor_BackgroundPictureSprites.size
      @actor_BackgroundPictureSprites[root_index] = Array.new()
      element = 0
      while(actorBP_Array[element]) do
        current_index   = @actor_BackgroundPictureSprites[root_index].size
        sprite          = Sprite.new()
        sprite.bitmap   = Cache.picture(actorBP_Array[element])
        sprite.opacity  = 0
        element += 1
        sprite.zoom_x   = actorBP_Array[element].to_f / sprite.bitmap.width
        element += 1
        sprite.zoom_y   = actorBP_Array[element].to_f / sprite.bitmap.height
        sprite.x        = ((Graphics.width * 0.5) - (actorBP_Array[element - 1] * 0.5))
        sprite.y        = 0
        sprite.z        = 100
        
        @actor_BackgroundPictureSprites[root_index][current_index] = sprite
        element += 1
      end
    end
    
    # Setup Character Images
    $game_system.dp3_status_screen_actor_characterimage_array.each do |index|
      sprite          = Sprite.new()
      sprite.bitmap   = Cache.picture(index[0])
      sprite.opacity  = 255
      sprite.zoom_x   = index[1].to_f / sprite.bitmap.width
      sprite.zoom_y   = index[2].to_f / sprite.bitmap.height
      sprite.x        = (Graphics.width * 0.75) - (index[1] * 0.3)
      sprite.y        = 0
      sprite.z        = 150
      sprite.visible  = false
      @actor_CharacterImage[@actor_CharacterImage.size] = sprite
    end
    
    @previous_bg_sprite = @current_bg_sprite = @actor_BackgroundPictureSprites[actor.id - 1][rand(@actor_BackgroundPictureSprites[actor.id - 1].size)]
    @currentframescount = @framesuntilswitchbg = (SecondsUntilSwitchBGImage * 60)
    @actor_CharacterImage[actor.id - 1].visible = true
    
    super( 0, 0, Graphics.width * 0.75, Graphics.height )
    @actor = actor
    refresh
    activate
    
    self.opacity = 0
    self.z = 244
    @description_helpwindow.opacity = 0
    @description_helpwindow.z = 255
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super()
    
    # Dipose of the help window
    @description_helpwindow.dispose()
        
    # Dispose of the Sprites that was created in initialisation
    @actor_BackgroundPictureSprites.each do |inner_array|
      inner_array.each do |element|
        element.bitmap.dispose() unless element.bitmap.disposed?
        element.dispose() unless element.disposed?
      end
    end
    
    @actor_CharacterImage.each do |element|
      element.bitmap.dispose() unless element.bitmap.disposed?
      element.dispose() unless element.disposed?
    end
  end
  #--------------------------------------------------------------------------
  # * New Method: Update
  #--------------------------------------------------------------------------
  def update()
    @current_bg_sprite.opacity  += 1 if @current_bg_sprite && @current_bg_sprite.opacity < 255
    @previous_bg_sprite.opacity -= 1 if @previous_bg_sprite && @previous_bg_sprite.opacity > 0
    
    @currentframescount += 1
    
    
    
    # ///// Update Character Image /////
    if (@currently_selected_actor_id != @actor.id)
      for i in 0..(@actor_CharacterImage.size - 1)
        @actor_CharacterImage[i].visible = (i == (@actor.id - 1)) ? true : false
      end
    end
      
    
    
    
    
    
    # ///// Update Background Images /////
    #=-=-=-=-=
    if @actor_BackgroundPictureSprites[@actor.id - 1] 
      #----------
      if @actor_BackgroundPictureSprites[@actor.id - 1].size > 1
        if (@currentframescount >= @framesuntilswitchbg) || (@currently_selected_actor_id != @actor.id)
          @currentframescount = 0
          @previous_bg_sprite = @current_bg_sprite
          while(@previous_bg_sprite == @current_bg_sprite) do
            @current_bg_sprite = @actor_BackgroundPictureSprites[@actor.id - 1][rand(@actor_BackgroundPictureSprites[@actor.id - 1].size)]
          end
        end
      #----------  
      else
        @current_bg_sprite = @actor_BackgroundPictureSprites[@actor.id - 1][0]
      end
    #=-=-=-=-=  
    else
      @current_bg_sprite.opacity -= 2   if @current_bg_sprite && @current_bg_sprite.opacity > 0
    end
    #=-=-=-=-=
    
    # Decrease Opacity for all unassigned images
    for innerarray in @actor_BackgroundPictureSprites
      for sprite in innerarray
        sprite.opacity -= 1 if sprite.opacity > 0 && sprite != @current_bg_sprite && sprite != @previous_bg_sprite
      end
    end
    
    
    # Fix Up what's left
    @currently_selected_actor_id  = @actor.id
    @current_bg_sprite.z          = 100    if @current_bg_sprite
    @previous_bg_sprite.z         = 101    if @previous_bg_sprite
    super()
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    @x = @y = 0
    draw_actor_name()
    draw_horz_line(@y) if ShowHLAfterName
    draw_actor_face()
    draw_actor_class()
    draw_actor_nickname() if ShowActorNickname && @actor.nickname != ""
    draw_actor_level()
    draw_actor_icons()
    draw_actor_hp()
    draw_actor_mp()
    draw_exp_info()
    draw_equipments()
    draw_parameters()
    draw_character_description()
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Name
  #--------------------------------------------------------------------------
  def draw_actor_name
    text = $game_system.dp3_status_screen_actor_fullname_array[@actor.id - 1]
    h = contents.font.size = 30
    if text
      w = (text.length * contents.font.size)
      x = ((self.width * 0.5) - ((text.length * 12) * 0.5))
      self.change_color(self.name_font_colour)
      self.draw_text(x, @y, w, h, text)
    end
    
    @y = contents.font.size
    contents.font.size = Font.default_size
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Face
  #--------------------------------------------------------------------------
  def draw_actor_face()
    @y += @h
    super(@actor, @x, @y)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Class
  #--------------------------------------------------------------------------
  def draw_actor_class
    @x = 100
    text =  "Class:     "
    self.change_color(self.class_label_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
    
    @x += text.length * 9
    text = @actor.class.name
    self.change_color(self.class_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Nickname
  #--------------------------------------------------------------------------
  def draw_actor_nickname()
    @x = 100; @y += @h
    text = "Nickname:  "
    self.change_color(self.nickname_label_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
  
    @x += text.length * 9
    text = @actor.nickname
    self.change_color(self.nickname_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Level
  #--------------------------------------------------------------------------
  def draw_actor_level()
    @x = 100; @y += @h
    text = "Level:     "
    self.change_color(self.level_label_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
    
    @x += text.length * 9
    text = @actor.level.to_s
    self.change_color(self.level_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
  end
  #--------------------------------------------------------------------------
  # * Draw Actor Icons
  #--------------------------------------------------------------------------
  def draw_actor_icons
    @x = 100; @y += @h
    text = "Status:    "
    self.change_color(self.status_label_font_colour)
    self.draw_text(@x, @y, @w, @h, text)
    
    @x += text.length * 9
    super( @actor, @x, @y )
  end
  #--------------------------------------------------------------------------
  # * Draw HP
  #--------------------------------------------------------------------------
  def draw_actor_hp()
    @x = 0; @y = 150; width = 180
    draw_gauge(@x, @y, width, @actor.hp_rate, self.hp_gauge_colour2, self.hp_gauge_colour)
    change_color(system_color)
    draw_text(@x, @y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(@x, @y, 96, @actor.hp, @actor.mhp, hp_color(@actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #--------------------------------------------------------------------------
  def draw_actor_mp()
    @y += @h; width = 180
    draw_gauge(@x, @y, width, @actor.mp_rate, self.mp_gauge_colour2, self.mp_gauge_colour)
    change_color(system_color)
    draw_text(@x, @y, 30, line_height, Vocab::mp_a)
    draw_current_and_max_values(@x, @y, 96, @actor.mp, @actor.mmp, mp_color(@actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Experience Information
  #--------------------------------------------------------------------------
  def draw_exp_info()
    @y += @h; width = 180
    exp_rate = @actor.exp.to_f / @actor.next_level_exp
    draw_gauge(@x, @y, width, exp_rate, self.exp_gauge_colour2, self.exp_gauge_colour)
    change_color(system_color)
    draw_text(@x, @y, 30, line_height, "Exp")
    draw_current_and_max_values(@x, @y, 96, @actor.exp, @actor.next_level_exp, normal_color, normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw Equipment
  #--------------------------------------------------------------------------
  def draw_equipments()
    @x = 200; @y = 155 + @h
    self.change_color(self.equipment_label_font_colour)
    draw_text(@x, @y, 200, line_height, "Equipment")
    self.change_color(self.equipment_font_colour)
    @y += @h
    @actor.equips.each_with_index do |item, i|
      draw_item_name(item, @x, (@y + (@h * i)), true, ((self.width - @x) - 48))
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Parameters
  #--------------------------------------------------------------------------
  def draw_parameters()
    @x = 0; @y = 150 + (@h * 4); rowdown = false
    6.times{ |i|  
      self.change_color(parameter_label_font_colour)
      text = Vocab::param(i + 2) + ": "
      draw_text(@x, @y, 60, @h, text)
      change_color(self.parameter_font_colour)
      draw_text(@x + (text.length * 12), @y, 36, @h, @actor.param(i + 2), 0)
      
      if rowdown
        @x = 0; @y += @h
        rowdown = false
      else
        @x = 90
        rowdown = true
      end
    }
  end
  #--------------------------------------------------------------------------
  # * Draw Character Description
  #--------------------------------------------------------------------------
  def draw_character_description()
    @description_helpwindow.change_color(self.description_font_colour)
    if $game_system.dp3_status_screen_actor_description_array[@actor.id - 1]
      @description_helpwindow.set_text($game_system.dp3_status_screen_actor_description_array[@actor.id - 1])
    else
      @description_helpwindow.set_text(@actor.description)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Custom Font/Gauge Colours
  #--------------------------------------------------------------------------
  def name_font_colour;             colour = get_colour( 0 );  colour = Color.new( *NameFontColour )            if !colour; return colour; end
  def class_label_font_colour;      colour = get_colour( 3 );  colour = Color.new( *ClassLabelFontColour )      if !colour; return colour; end
  def class_font_colour;            colour = get_colour( 6 );  colour = Color.new( *ClassFontColour )           if !colour; return colour; end
  def nickname_label_font_colour;   colour = get_colour( 9 );  colour = Color.new( *NicknameLabelFontColour )   if !colour; return colour; end
  def nickname_font_colour;         colour = get_colour( 12 ); colour = Color.new( *NicknameFontColour )        if !colour; return colour; end
  def level_label_font_colour;      colour = get_colour( 15 ); colour = Color.new( *LevelLabelFontColour )      if !colour; return colour; end
  def level_font_colour;            colour = get_colour( 18 ); colour = Color.new( *LevelFontColour )           if !colour; return colour; end
  def status_label_font_colour;     colour = get_colour( 21 ); colour = Color.new( *StatusLabelFontColour )     if !colour; return colour; end
  def equipment_label_font_colour;  colour = get_colour( 24 ); colour = Color.new( *EquipmentLabelFontColour )  if !colour; return colour; end
  def equipment_font_colour;        colour = get_colour( 27 ); colour = Color.new( *EquipmentFontColour )       if !colour; return colour; end
  def parameter_label_font_colour;  colour = get_colour( 30 ); colour = Color.new( *ParameterLabelFontColour )  if !colour; return colour; end
  def parameter_font_colour;        colour = get_colour( 33 ); colour = Color.new( *ParameterFontColour )       if !colour; return colour; end
  def description_font_colour;      colour = get_colour( 36 ); colour = Color.new( *DescriptionFontColour )     if !colour; return colour; end
  def hp_gauge_colour;              colour = get_colour( 39 ); colour = Color.new( *HP_GaugeColour )            if !colour; return colour; end
  def mp_gauge_colour;              colour = get_colour( 42 ); colour = Color.new( *MP_GaugeColour )            if !colour; return colour; end
  def exp_gauge_colour;             colour = get_colour( 45 ); colour = Color.new( *EXP_GaugeColour )           if !colour; return colour; end

  def hp_gauge_colour2
    colour = hp_gauge_colour
    Color.new( colour.red * 0.5, colour.green * 0.5, colour.blue * 0.5 )
  end
  def mp_gauge_colour2
    colour = mp_gauge_colour
    Color.new( colour.red * 0.5, colour.green * 0.5, colour.blue * 0.5 )
  end
  
  def exp_gauge_colour2
    colour = exp_gauge_colour
    Color.new( colour.red * 0.5, colour.green * 0.5, colour.blue * 0.5 )
  end
  
  def get_colour( index )
    index = index + ((@actor.id - 1) * 48)
    colour_array = $game_system.dp3_status_screen_actor_font_gauge_colour_array
    if colour_array[index] && colour_array[index + 1] && colour_array[index + 2]
      return Color.new( colour_array[index], colour_array[index + 1], colour_array[index + 2] )
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Redefined Method: Draw Current and Max Values
  #--------------------------------------------------------------------------
  def draw_current_and_max_values(x, y, width, current, max, color1, color2)
    change_color(color1)
    xr = x + width
    if width < 96
      draw_text(xr - 40, y, 42, line_height, current, 2)
    else
      text = current.to_s + " / " + max.to_s
      xpos = xr - ((text.length * 12) * 0.5)
      draw_text(xpos, y, 200, line_height, text, 1)
    end
  end
end















#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draw Text with Control Characters
  #--------------------------------------------------------------------------
  alias dp3_windowbase_drawtextex_2038ufs   draw_text_ex
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    if SceneManager.scene_is?(Scene_Status)
      text = convert_escape_characters(text)
      pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
      process_character(text.slice!(0, 1), text, pos) until text.empty?
    else
      dp3_windowbase_drawtextex_2038ufs(x, y, text)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item Name
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  alias dp3_windowbase_drawitemname_2038ufs     draw_item_name
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    if SceneManager.scene_is?(Scene_Status)
      return unless item
      draw_icon(item.icon_index, x, y, enabled)
      draw_text(x + 24, y, width, line_height, item.name)
    else
      dp3_windowbase_drawitemname_2038ufs( item, x, y, enabled, width)
    end
  end
end















#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # * New Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :dp3_status_screen_actor_fullname_array
  attr_accessor :dp3_status_screen_actor_font_gauge_colour_array  
  attr_accessor :dp3_status_screen_actor_backgroundimages_array
  attr_accessor :dp3_status_screen_actor_characterimage_array 
  attr_accessor :dp3_status_screen_actor_description_array
  #--------------------------------------------------------------------------
  # * Aliased Method: Object Initialization
  #--------------------------------------------------------------------------
  alias dp3_gamesystem_initialize_283yfj2     initialize
  #--------------------------------------------------------------------------
  def initialize( *args )
    @dp3_status_screen_actor_fullname_array = DiamondandPlatinum3::StatusScreenOptions::CharacterDisplayName
    @dp3_status_screen_actor_font_gauge_colour_array = 
    [
      *DiamondandPlatinum3::StatusScreenOptions::NameFontColour,  
      *DiamondandPlatinum3::StatusScreenOptions::ClassLabelFontColour,
      *DiamondandPlatinum3::StatusScreenOptions::ClassFontColour, 
      *DiamondandPlatinum3::StatusScreenOptions::NicknameLabelFontColour,
      *DiamondandPlatinum3::StatusScreenOptions::NicknameFontColour,        
      *DiamondandPlatinum3::StatusScreenOptions::LevelLabelFontColour,  
      *DiamondandPlatinum3::StatusScreenOptions::LevelFontColour,     
      *DiamondandPlatinum3::StatusScreenOptions::StatusLabelFontColour,
      *DiamondandPlatinum3::StatusScreenOptions::EquipmentLabelFontColour,  
      *DiamondandPlatinum3::StatusScreenOptions::EquipmentFontColour,  
      *DiamondandPlatinum3::StatusScreenOptions::ParameterLabelFontColour,
      *DiamondandPlatinum3::StatusScreenOptions::ParameterFontColour,
      *DiamondandPlatinum3::StatusScreenOptions::DescriptionFontColour,
      *DiamondandPlatinum3::StatusScreenOptions::HP_GaugeColour,     
      *DiamondandPlatinum3::StatusScreenOptions::MP_GaugeColour,            
      *DiamondandPlatinum3::StatusScreenOptions::EXP_GaugeColour,
    ]
    @dp3_status_screen_actor_backgroundimages_array = DiamondandPlatinum3::StatusScreenOptions::BackgroundPictures
    @dp3_status_screen_actor_characterimage_array = DiamondandPlatinum3::StatusScreenOptions::CharacterImage
    @dp3_status_screen_actor_description_array = []
    # Call Original Method
    dp3_gamesystem_initialize_283yfj2( *args )
  end
  #--------------------------------------------------------------------------
  # * New Method: Get Actor ID
  #--------------------------------------------------------------------------
  def dp3_status_screen_get_actor_id( actor )
    actor_id = actor.is_a?(Integer) ? actor : nil
    if actor.is_a?(String)
      for i in 1..($data_actors.size - 1)
        if $game_actors[i].name.upcase == actor.upcase
          actor_id = $game_actors[i].id
          break
        end
      end
    end
    return actor_id
  end
  #--------------------------------------------------------------------------
  # * New Method: Modify Status Screen Actor Full Name
  #--------------------------------------------------------------------------
  def dp3_modify_status_screen_actor_full_name( actor, sName )
    actor_id = dp3_status_screen_get_actor_id( actor )
    return if !actor_id || !sName.is_a?(String)
    @dp3_status_screen_actor_fullname_array[actor_id - 1] = sName
  end
  #--------------------------------------------------------------------------
  # * New Method: Modify Status Screen Font Options
  #--------------------------------------------------------------------------
  def dp3_modify_status_screen_font_gauge_options( actor, sOption, iRed, iGreen, iBlue )
    # Get Actor ID
    actor_id = dp3_status_screen_get_actor_id( actor )
    return if !actor_id || !sOption.is_a?(String)
    #~~~~~~~~~~~~~~~~~~~~~~~~
    # While we don't have specified font colours for an actor, make it the default colours
    while @dp3_status_screen_actor_font_gauge_colour_array.size < actor_id * 48
      array = 
      [
        *DiamondandPlatinum3::StatusScreenOptions::NameFontColour,  
        *DiamondandPlatinum3::StatusScreenOptions::ClassLabelFontColour,
        *DiamondandPlatinum3::StatusScreenOptions::ClassFontColour, 
        *DiamondandPlatinum3::StatusScreenOptions::NicknameLabelFontColour,
        *DiamondandPlatinum3::StatusScreenOptions::NicknameFontColour,        
        *DiamondandPlatinum3::StatusScreenOptions::LevelLabelFontColour,  
        *DiamondandPlatinum3::StatusScreenOptions::LevelFontColour,     
        *DiamondandPlatinum3::StatusScreenOptions::StatusLabelFontColour,
        *DiamondandPlatinum3::StatusScreenOptions::EquipmentLabelFontColour,  
        *DiamondandPlatinum3::StatusScreenOptions::EquipmentFontColour,  
        *DiamondandPlatinum3::StatusScreenOptions::ParameterLabelFontColour,
        *DiamondandPlatinum3::StatusScreenOptions::ParameterFontColour,
        *DiamondandPlatinum3::StatusScreenOptions::DescriptionFontColour,
        *DiamondandPlatinum3::StatusScreenOptions::HP_GaugeColour,     
        *DiamondandPlatinum3::StatusScreenOptions::MP_GaugeColour,            
        *DiamondandPlatinum3::StatusScreenOptions::EXP_GaugeColour,
      ]
      # Now put them into our instance array
      array.each do |element|
        index = @dp3_status_screen_actor_font_gauge_colour_array.size
        @dp3_status_screen_actor_font_gauge_colour_array[index] = element
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~
    index = nil
    case sOption.upcase
    when "NAMEFONTCOLOUR"
      index = [ 0, 1, 2 ]
    when "CLASSLABELFONTCOLOUR"
      index = [ 3, 4, 5 ]
    when "CLASSFONTCOLOUR"
      index = [ 6, 7, 8 ]
    when "NICKNAMELABELFONTCOLOUR"
      index = [ 9, 10, 11 ]
    when "NICKNAMEFONTCOLOUR"
      index = [ 12, 13, 14 ]
    when "LEVELLABELFONTCOLOUR"
      index = [ 15, 16, 17 ]
    when "LEVELFONTCOLOUR"
      index = [ 18, 19, 20 ]
    when "STATUSLABELFONTCOLOUR"
      index = [ 21, 22, 23 ]
    when "EQUIPMENTLABELFONTCOLOUR"
      index = [ 24, 25, 26 ]
    when "EQUIPMENTFONTCOLOUR"
      index = [ 27, 28, 29 ]
    when "PARAMETERLABELFONTCOLOUR"
      index = [ 30, 31, 32 ]
    when "PARAMETERFONTCOLOUR"
      index = [ 33, 34, 35 ]
    when "DESCRIPTIONFONTCOLOUR"
      index = [ 36, 37, 38 ]
    when "HP_GAUGECOLOUR"
      index = [ 39, 40, 41 ]
    when "MP_GAUGECOLOUR"
      index = [ 42, 43, 44 ]
    when "EXP_GAUGECOLOUR"
      index = [ 45, 46, 47 ]
    end
    return if !index || index.size < 3
    #~~~~~~~~~~~~~~~~~~~~~~~~
    # Use the actor id multiplied by the size of specific actor space of the array to get the actual index position
    index[0] += ((actor_id - 1) * 48); index[1] += ((actor_id - 1) * 48); index[1] += ((actor_id - 1) * 48)
    @dp3_status_screen_actor_font_gauge_colour_array[index[0]] = iRed
    @dp3_status_screen_actor_font_gauge_colour_array[index[1]] = iGreen
    @dp3_status_screen_actor_font_gauge_colour_array[index[2]] = iBlue
  end
  #--------------------------------------------------------------------------
  # * New Method: Add A Background Image to Status Screen
  #--------------------------------------------------------------------------
  def dp3_status_screen_add_background_image( actor, sImageName, width, height )
    actor_id = dp3_status_screen_get_actor_id( actor )
    return if !actor_id || !sImageName.is_a?(String) || !width.is_a?(Integer) || !height.is_a?(Integer)
    
    # If an actor if out of range, keep making arrays until the size is up to scratch
    while( @dp3_status_screen_actor_backgroundimages_array.size < actor_id )
      index = @dp3_status_screen_actor_backgroundimages_array.size
      @dp3_status_screen_actor_backgroundimages_array[index] = Array.new()
    end
    
    inner_index = @dp3_status_screen_actor_backgroundimages_array[actor_id - 1].size
    @dp3_status_screen_actor_backgroundimages_array[actor_id - 1][inner_index] = sImageName
    @dp3_status_screen_actor_backgroundimages_array[actor_id - 1][inner_index + 1] = width
    @dp3_status_screen_actor_backgroundimages_array[actor_id - 1][inner_index + 2] = height
  end
  #--------------------------------------------------------------------------
  # * New Method: Remove A Background Image from Status Screen
  #--------------------------------------------------------------------------
  def dp3_status_screen_remove_background_image( actor, sImageName )
    actor_id = dp3_status_screen_get_actor_id( actor )
    return if !actor_id || !sImageName.is_a?(String)
    
    if @dp3_status_screen_actor_backgroundimages_array[actor_id - 1]
      index = 0; foundimage = false
      for imagename in @dp3_status_screen_actor_backgroundimages_array[actor_id - 1]
        if imagename.is_a?(String) && imagename == sImageName
          foundimage = true; break;
        else
          index += 1
        end
      end
      if foundimage
        @dp3_status_screen_actor_backgroundimages_array[actor_id - 1].delete_at( index + 2 )
        @dp3_status_screen_actor_backgroundimages_array[actor_id - 1].delete_at( index + 1 )
        @dp3_status_screen_actor_backgroundimages_array[actor_id - 1].delete_at( index )
      end
    end
  end
  #--------------------------------------------------------------------------
  # * New Method: Change a Character Image for Status Screen
  #--------------------------------------------------------------------------
  def dp3_status_screen_change_character_image( actor, sImageName, width, height )
    actor_id = dp3_status_screen_get_actor_id( actor )
    return if !actor_id || !sImageName.is_a?(String) || !width.is_a?(Integer) || !height.is_a?(Integer)
  
    # If an actor if out of range, keep making arrays until the size is up to scratch
    while( @dp3_status_screen_actor_characterimage_array < actor_id )
      index = @dp3_status_screen_actor_characterimage_array.size
      @dp3_status_screen_actor_characterimage_array[index] = Array.new()
    end
    
    @dp3_status_screen_actor_characterimage_array[actor_id - 1][0] = sImageName
    @dp3_status_screen_actor_characterimage_array[actor_id - 1][1] = width
    @dp3_status_screen_actor_characterimage_array[actor_id - 1][2] = height
  end
  #--------------------------------------------------------------------------
  # * New Method: Change a Character's Description for Status Screen
  #--------------------------------------------------------------------------
  def dp3_status_screen_modify_character_description( actor, description )
    actor_id = dp3_status_screen_get_actor_id( actor )
    return if !actor_id || !description.is_a?(String)
    while @dp3_status_screen_actor_description_array.size < actor_id
      @dp3_status_screen_actor_description_array[@dp3_status_screen_actor_description_array.size] = ""
    end
    @dp3_status_screen_actor_description_array[actor_id - 1] = description
  end
end














#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * New Method: Modify Status Screen Actor Full Name
  #--------------------------------------------------------------------------
  def status_screen_modify_actor_full_name( actor, sName )
    $game_system.dp3_modify_status_screen_actor_full_name( actor, sName )
  end
  #--------------------------------------------------------------------------
  # * New Method: Modify Status Screen Font Options
  #--------------------------------------------------------------------------
  def status_screen_modify_font_gauge_options( actor, sOption, iRed, iGreen, iBlue )
    $game_system.dp3_modify_status_screen_font_gauge_options( actor, sOption, iRed, iGreen, iBlue )
  end
  #--------------------------------------------------------------------------
  # * New Method: Add A Background Image to Status Screen
  #--------------------------------------------------------------------------
  def status_screen_add_background_image( actor, sImageName, width, height )
    $game_system.dp3_status_screen_add_background_image( actor, sImageName, width, height )
  end
  #--------------------------------------------------------------------------
  # * New Method: Remove A Background Image from Status Screen
  #--------------------------------------------------------------------------
  def status_screen_remove_background_image( actor, sImageName )
    $game_system.dp3_status_screen_remove_background_image( actor, sImageName )
  end
  #--------------------------------------------------------------------------
  # * New Method: Change a Character Image for Status Screen
  #--------------------------------------------------------------------------
  def status_screen_change_character_image( actor, sImageName, width, height )
    $game_system.dp3_status_screen_change_character_image( actor, sImageName, width, height )
  end
  #--------------------------------------------------------------------------
  # * New Method: Change a Character's Description for Status Screen
  #--------------------------------------------------------------------------
  def status_screen_change_character_description( actor, description )
    $game_system.dp3_status_screen_modify_character_description( actor, description )
  end
end