#=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
# ** One Hero Menu  **
# 
# Author:   eugene222
# Version:  1.1
# Date:     20.04.2014
#=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
#
# * Changelog:
#   
#     20.04.2014:     Script Created
#     06.05.2014:     Added option to scroll between actors
#     
#=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
#
# * Terms of Use:
#
#   You are free to use this script commercially or non-commercially as long as
#   you credit me.
#
#=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
# * Description:
#
#     Changes the look of the main menu to only show one actor
#     You can configure the menu below.
#
#     The actors will scroll if you press the L and R Buttons.
#     The L and R Buttons should be the Q and R Buttons on your Keyboard
#     This function is similar to the scrolling in Scene_Status
#
#=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
module MenuConfig
  #-----------------------------------------------------------------------------
  # The positions of the command window:
  #   - possibilities: :left, :right, :top, :bot
  #-----------------------------------------------------------------------------
  CMD_POS = :right
  
  #-----------------------------------------------------------------------------
  # Enable or Disable the L and R Scroll Feature
  #-----------------------------------------------------------------------------
  LR_ACTOR_SCROLL = true   
   
  #-----------------------------------------------------------------------------
  # Should the command window be a bit wider? (good if you use icons on text)
  # - this only works for left or right position command window
  #-----------------------------------------------------------------------------
  WIDER_COMMAND_MENU = false
       
  #-----------------------------------------------------------------------------
  # Show the Actor Name and Class over the face? => true
  # Show the Text and Face seperated => false
  #-----------------------------------------------------------------------------
  TEXT_OVER_FACE = false
       
  #-----------------------------------------------------------------------------
  # Which Lines should be shown?
  #-----------------------------------------------------------------------------
  LINES = [false, true, true, true]
       
  #-----------------------------------------------------------------------------
  # Below you can configure which parts will be shown and which not
  #-----------------------------------------------------------------------------
  SHOW = { # Diese Zeile nicht veränder!
  #-----------------------------------------------------------------------------
         
    location:   true,     # Map-Name
    class_name: true,     # Class-Name
         
    icons:      true,     # State-Icons
         
    mp_gauge:   true,     # MP Gauge
    tp_gauge:   true,     # TP Gauge
    exp_gauge:  true,     # EXP Gauge
         
  #-----------------------------------------------------------------------------
  } # Diese Zeile nicht verändern
  #-----------------------------------------------------------------------------
  # Put class-name one line lower if one gauge is deactivated and
  # TEXT_OVER_FACE is false?
  #-----------------------------------------------------------------------------
  CLASS_NAME_AUTO_POS = false
       
  #-----------------------------------------------------------------------------
  # Icon IDs:
  #-----------------------------------------------------------------------------
  LOCATION_ICON = 231
  GOLD_ICON = 361
       
  #-----------------------------------------------------------------------------
  # Colors for Text and Gauges:
  # The window-skin colors are used
  #-----------------------------------------------------------------------------
  COLOR_IDS = { # Diese Zeile nicht verändern !
  #-----------------------------------------------------------------------------
       
    class_text:       2,
    name_text:        3,
    location_text:    6,
    gold_text:        0,
         
    exp_gauge_start:  14,
    exp_gauge_end:    6,
         
  #-----------------------------------------------------------------------------  
  } # Diese Zeile nicht verändern !
  #-----------------------------------------------------------------------------
  # What will be shown at the bottom part of the menu?
  #     A one line text?                  => :objective
  #     - You can set the text with the Scriptcall: "set_menu_objective("Text")"
  #
  #     Your own variable and the gold?   => :variables
  #-----------------------------------------------------------------------------
       
  BOTTOM_AREA = :variables
       
  #-----------------------------------------------------------------------------
  # If BOTTOM_AREA = :variables
  #          [Variable-ID, Icon-Index, Text-Color (Window-Skin Index)]
  #-----------------------------------------------------------------------------
  VARIABLE = [1, 172, 0]  
      
  #-----------------------------------------------------------------------------
  # CONFIG END
  #-----------------------------------------------------------------------------
end
#===============================================================================
# ** Game Party and Game Interpreter
#===============================================================================
if MenuConfig::BOTTOM_AREA == :objective
#-------------------------------------------------------------------------------
class Game_Party < Game_Unit
  attr_accessor   :objective_description
end
#-------------------------------------------------------------------------------
class Game_Interpreter
  def set_menu_objective(obj)
    return unless obj.is_a? String
    $game_party.objective_description = obj
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
# ** Window Base
#===============================================================================
class Window_Base
  #-----------------------------------------------------------------------------
  # * Draw Horizontal Line
  #-----------------------------------------------------------------------------
  def draw_horz_line_e222(x, y, width = contents_width)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(x, line_y, width, 2, line_color)
  end
  #-----------------------------------------------------------------------------
  # * Line Color
  #-----------------------------------------------------------------------------  
  def line_color
    color = normal_color
    color.alpha = 48
    color
  end
  #-----------------------------------------------------------------------------
  # * Draw Face With Rect
  #-----------------------------------------------------------------------------  
  def draw_face_with_rect(face_name, face_index, x, y)
    contents.fill_rect(x, y, 100, 100, Color.new(0, 0, 0, 128))
    contents.clear_rect(x + 2, y + 2, 96, 96)
    draw_face(face_name, face_index, x + 2, y + 2)
  end
  #-----------------------------------------------------------------------------
  # * Draw Paramaters In Two Rows
  #-----------------------------------------------------------------------------
  def draw_parameters_e222(actor, x, y, l_x = 160)
    6.times do |i|
      n_x = i > 2 ? l_x : x
      n_i = i % 3
      draw_actor_param(actor, n_x, y + line_height * n_i, i + 2) 
    end
  end
  #-----------------------------------------------------------------------------
  # * Draw Actor EXP Gauge
  #-----------------------------------------------------------------------------
  def draw_actor_exp_g(actor, x, y, width = 124)
    exp_now = actor.exp - actor.current_level_exp
    exp_need  = actor.next_level_exp.to_f - actor.current_level_exp
    exp_rate = actor.max_level? ? 1 : exp_now / exp_need
    draw_gauge(x, y, width, exp_rate, exp_color1, exp_color2)
    draw_actor_level(actor, x, y)
    exp_text = sprintf(sprintf '%d%%', 100 * exp_rate)
    draw_text(x + width - 42, y, 42, line_height, exp_text, 2)
  end
  #-----------------------------------------------------------------------------
  # * EXP Color 1
  #-----------------------------------------------------------------------------
  def exp_color1
    text_color(MenuConfig::COLOR_IDS[:exp_gauge_start])
  end
  #-----------------------------------------------------------------------------
  # * EXP Color 2
  #-----------------------------------------------------------------------------
  def exp_color2
    text_color(MenuConfig::COLOR_IDS[:exp_gauge_end])
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# ** Window One Actor Menu Status
#===============================================================================
class Window_OneMenuStatus < Window_Selectable
  #-----------------------------------------------------------------------------
  include MenuConfig
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize(x)
    super(window_x(x), window_y, window_width, window_height)
    refresh
  end
  #-----------------------------------------------------------------------------
  # * Return Actor
  #-----------------------------------------------------------------------------
  def actor
    return $game_party.menu_actor if MenuConfig::LR_ACTOR_SCROLL
    $game_party.all_members.first
  end
  #-----------------------------------------------------------------------------
  # * Window X
  #-----------------------------------------------------------------------------
  def window_x(x)
    case CMD_POS
    when  :top, :bot
      (Graphics.width - window_width) / 2
    when :right
      WIDER_COMMAND_MENU ? 6 : 12
    else
      x + (WIDER_COMMAND_MENU ? 6 : 24)
    end
  end
  #-----------------------------------------------------------------------------
  # * Window Y
  #-----------------------------------------------------------------------------
  def window_y
    case MenuConfig::CMD_POS
    when :left, :right
      (Graphics.height - window_height) / 2
    when :bot
      12
    else
      fitting_height(2) + 24
    end
  end
  #-----------------------------------------------------------------------------
  # * Window Width
  #-----------------------------------------------------------------------------
  def window_width
    Graphics.width - 164
  end
  #-----------------------------------------------------------------------------
  # * Window Height
  #-----------------------------------------------------------------------------
  def window_height
    Graphics.height - fitting_height(2) - 36
  end
  #-----------------------------------------------------------------------------
  # * Right Side X
  #-----------------------------------------------------------------------------
  def right_side_x
    contents.width - 140
  end
  #-----------------------------------------------------------------------------
  # * Name and Class alignment
  #-----------------------------------------------------------------------------
  def name_class_alignment
    MenuConfig::TEXT_OVER_FACE ? 1 : 0
  end
  #-----------------------------------------------------------------------------
  # * Refresh
  #-----------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_lines
    draw_player_info
    draw_location(right_side_x, 0)
    draw_player_gauges
    draw_gold
    draw_bottom_area
  end
  #-----------------------------------------------------------------------------
  # * Draw Lines
  #-----------------------------------------------------------------------------
  def draw_lines
    if LINES[0]
      width = TEXT_OVER_FACE ? contents.width - 112 : contents.width
      x     = TEXT_OVER_FACE ? 112 : 0
      draw_horz_line_e222(x, 2, width)
    end
    draw_horz_line_e222(0, line_height * 5)   if LINES[1] 
    draw_horz_line_e222(0, line_height * 9)   if LINES[2]
    draw_horz_line_e222(0, line_height * 11)  if LINES[3]
  end
  #-----------------------------------------------------------------------------
  # * Draw Player Info
  #-----------------------------------------------------------------------------
  def draw_player_info
    draw_player_face
    draw_player_name
    draw_player_class
    draw_actor_icons(actor, 250, line_height * 1.5)
    draw_parameters_e222(actor, 0,  line_height * 6, contents.width - 156)
  end
  #-----------------------------------------------------------------------------
  # * Draw Player Face
  #-----------------------------------------------------------------------------
  def draw_player_face
    x = TEXT_OVER_FACE ? 6 : 0
    y = TEXT_OVER_FACE ? 12 : 24
    draw_face_with_rect(actor.face_name, actor.face_index, x, y)
  end
  #-----------------------------------------------------------------------------
  # * Draw Player Name
  #-----------------------------------------------------------------------------
  def draw_player_name
    change_color(text_color(COLOR_IDS[:name_text]))
    draw_text(0, 0, 112, line_height, actor.name, name_class_alignment)
  end
  #-----------------------------------------------------------------------------
  # * Draw Player Class
  #-----------------------------------------------------------------------------
  def draw_player_class
    return unless SHOW[:class_name]
    change_color(text_color(COLOR_IDS[:class_text]))
    x = TEXT_OVER_FACE ? 0 : 112
    y_modifier = hide_any_gauge? ? 1 : 0
    y = TEXT_OVER_FACE ? line_height * 4 : line_height * y_modifier 
    draw_text(x, y, 108, line_height, actor.class.name, name_class_alignment)
  end
  #-----------------------------------------------------------------------------
  # * Draw Location
  #-----------------------------------------------------------------------------
  def draw_location(x, y)
    return unless SHOW[:location]
    change_color(text_color(COLOR_IDS[:location_text]))
    draw_text(x, y, 112, line_height, $game_map.display_name, 2)
    draw_icon(LOCATION_ICON, x + 114, y)
  end
  #-----------------------------------------------------------------------------
  # * Draw PLayer Gauges
  #-----------------------------------------------------------------------------
  def draw_player_gauges
    if SHOW[:exp_gauge]
      draw_actor_exp_g(actor, 112, line_height * 4, contents.width - 112)
    end
    draw_actor_hp
    draw_actor_mp
    draw_actor_tp 
  end
  #-----------------------------------------------------------------------------
  # * Draw Actor HP
  #-----------------------------------------------------------------------------
  def draw_actor_hp
    y_modifier  = SHOW[:tp_gauge] ? 1 : 2
    y_modifier += (SHOW[:mp_gauge] ? 0 : 1)
    y_modifier += (SHOW[:exp_gauge] ? 0 : 1)
    super(actor, 112, line_height * y_modifier)
  end
  #-----------------------------------------------------------------------------
  # * Draw Actor MP
  #-----------------------------------------------------------------------------
  def draw_actor_mp
    return unless SHOW[:mp_gauge]
    y_modifier = SHOW[:tp_gauge] ? 2 : 3
    y_modifier += (SHOW[:exp_gauge] ? 0 : 1)
    super(actor, 112, line_height * y_modifier)
  end
  #-----------------------------------------------------------------------------
  # * Draw Actor TP
  #-----------------------------------------------------------------------------
  def draw_actor_tp
    return unless SHOW[:tp_gauge]
    y_modifier = SHOW[:exp_gauge] ? 3 : 4
    super(actor, 112, line_height * y_modifier)
  end
  #-----------------------------------------------------------------------------
  # * Draw State and Buff/Debuff Icons
  #-----------------------------------------------------------------------------
  def draw_actor_icons(actor, x, y)
    return unless SHOW[:icons]
    icons = (actor.state_icons + actor.buff_icons)[0, 8]
    icons.each_with_index do |n, i|
      n_y = i > 3 ? y + line_height : y
      n_i = i % 4
      draw_icon(n, x + 24 * n_i, n_y) 
    end
  end
  #-----------------------------------------------------------------------------
  # * Draw Buttom Area
  #-----------------------------------------------------------------------------
  def draw_bottom_area
   if BOTTOM_AREA == :objective
     draw_objective(0, line_height * 10)
    else
      draw_variable
    end
  end
  #-----------------------------------------------------------------------------
  # * Draw Objective
  #-----------------------------------------------------------------------------
  def draw_objective(x, y)
    return unless $game_party.objective_description
    desc = $game_party.objective_description.gsub("\n", "")
    draw_text(x, y, contents.width, line_height, desc)
  end
  #-----------------------------------------------------------------------------
  # * Draw Gold
  #-----------------------------------------------------------------------------
  def draw_gold
    change_color(text_color(COLOR_IDS[:gold_text]))
    x = contents.width - 156
    y = line_height * (BOTTOM_AREA != :objective ? 10 : 11)
    draw_text(x, y, 130, line_height, $game_party.gold, 2)
    draw_icon(MenuConfig::GOLD_ICON, x + 132, y)
  end
  #-----------------------------------------------------------------------------
  # * Draw Variable
  #-----------------------------------------------------------------------------
  def draw_variable
    change_color(text_color(VARIABLE[2]))
    var = $game_variables[VARIABLE[0]]
    draw_text(0, line_height * 10, 130, line_height, var, 2)
    draw_icon(VARIABLE[1], 132, line_height * 10)
  end
  #-----------------------------------------------------------------------------
  # * Is any Gauge deactivated?
  #-----------------------------------------------------------------------------
  def hide_any_gauge?
    !(SHOW[:mp_gauge] && SHOW[:tp_gauge] && SHOW[:exp_gauge]) &&
    CLASS_NAME_AUTO_POS
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# ** Window Menu Command
#===============================================================================
class Window_MenuCommand < Window_Command
  #-----------------------------------------------------------------------------
  # * Initialize
  #-----------------------------------------------------------------------------
  def initialize
    super(window_x, window_y)
    select_last
  end
  #-----------------------------------------------------------------------------
  # * Spacing
  #-----------------------------------------------------------------------------
  def spacing
    return 4
  end
  #-----------------------------------------------------------------------------
  # * Col Max
  #-----------------------------------------------------------------------------
  def col_max
    case MenuConfig::CMD_POS
    when :left, :right
      return 1
    else
      return 3
    end
  end
  #-----------------------------------------------------------------------------
  # * Window Width
  #-----------------------------------------------------------------------------
  def window_width
    case MenuConfig::CMD_POS
    when :left, :right
      return (MenuConfig::WIDER_COMMAND_MENU ? 152 : 128)
    else
      Graphics.width - 128 - 36
    end
  end
  #-----------------------------------------------------------------------------
  # * Window Height
  #-----------------------------------------------------------------------------
  def window_height
    case MenuConfig::CMD_POS
    when :left, :right
      fitting_height(visible_line_number)
    else
      fitting_height(2)
    end
  end
  #-----------------------------------------------------------------------------
  # * Window X
  #-----------------------------------------------------------------------------
  def window_x
    case MenuConfig::CMD_POS
    when :top, :bot
      (Graphics.width - window_width) / 2
    when :left
      MenuConfig::WIDER_COMMAND_MENU ? 6 : 12
    else
      Graphics.width - (MenuConfig::WIDER_COMMAND_MENU ? 158 : 140)
    end
  end
  #-----------------------------------------------------------------------------
  # * Window Y
  #-----------------------------------------------------------------------------
  def window_y
    case MenuConfig::CMD_POS
    when :left, :right
      (Graphics.height - (Graphics.height - fitting_height(2) - 36)) / 2
    when :top
      12
    else
      Graphics.height - fitting_height(2) - 36 + 24
    end
  end
  #-----------------------------------------------------------------------------
  # * Remove Formation Command
  #-----------------------------------------------------------------------------
  def add_formation_command
    return
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# ** Scene_Menu
#===============================================================================
class Scene_Menu < Scene_MenuBase
  #-----------------------------------------------------------------------------
  # * Start Processing
  #-----------------------------------------------------------------------------
  def start
    super
    create_command_window
    create_status_window
    override_handlers
  end
  #-----------------------------------------------------------------------------
  # * Override Handlers
  #-----------------------------------------------------------------------------
  def override_handlers
    @command_window.set_handler(:skill,     method(:command_skill))
    @command_window.set_handler(:equip,     method(:command_equip))
    @command_window.set_handler(:status,    method(:command_status))
    @command_window.set_handler(:cancel,    method(:return_scene))
    return unless MenuConfig::LR_ACTOR_SCROLL
    @command_window.set_handler(:pagedown,  method(:next_actor))
    @command_window.set_handler(:pageup,    method(:prev_actor))
  end
  #-----------------------------------------------------------------------------
  # * Command Skill
  #-----------------------------------------------------------------------------
  def command_skill
    SceneManager.call(Scene_Skill)
  end
  #-----------------------------------------------------------------------------
  # * Command Equip
  #-----------------------------------------------------------------------------
  def command_equip
    SceneManager.call(Scene_Equip)
  end
  #-----------------------------------------------------------------------------
  # * Command Status
  #-----------------------------------------------------------------------------
  def command_status
    SceneManager.call(Scene_Status)
  end
  #-----------------------------------------------------------------------------
  # * Create Status Window
  #-----------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_OneMenuStatus.new(@command_window.width)
  end
  #-----------------------------------------------------------------------------
  # On Actor Change
  #-----------------------------------------------------------------------------
  def on_actor_change
    @command_window.activate
    @status_window.refresh
  end
  #-----------------------------------------------------------------------------
  # Return Scene
  #-----------------------------------------------------------------------------
  def return_scene
    $game_party.menu_actor = $game_party.all_members.first
    super
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# ** SCRIPT END
#===============================================================================