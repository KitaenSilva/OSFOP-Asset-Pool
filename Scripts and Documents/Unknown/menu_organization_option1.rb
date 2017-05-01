module MOD
#==============================================================================
#                          Menu Modification Begins
#------------------------------------------------------------------------------
# ● Font Configuration
#------------------------------------------------------------------------------
  Font.default_name      = ["THSpatial", "THSpatial", "THSpatial"]
  Font.default_size      = 10
  Font.default_bold      = false
  Font.default_italic    = false
  Font.default_shadow    = false
  Font.default_outline   = true
  Font.default_color     = Color.new(255, 255, 255, 255)
  Font.default_out_color = Color.new(0, 0, 0, 182)
#------------------------------------------------------------------------------
# ● Windowskin Graphics
#------------------------------------------------------------------------------
  WINDOW = ("Window")
#==============================================================================
# ▼ Object Initialization
#       x : window X coordinate
#       y : window Y coordinate
#------------------------------------------------------------------------------
# ● Logo Window [Main Menu]
#------------------------------------------------------------------------------
  LogoX = 0
  LogoY = 0
#------------------------------------------------------------------------------
# ● Health Window
#------------------------------------------------------------------------------
  HealthX = 0
  HealthY = 48
#------------------------------------------------------------------------------
# ● Mana Window
#------------------------------------------------------------------------------
  ManaX = 160
  ManaY = 48
#------------------------------------------------------------------------------
# ● Level Window
#------------------------------------------------------------------------------
  LevelX = 0
  LevelY = 123
#------------------------------------------------------------------------------
# ● Experience Window
#------------------------------------------------------------------------------
  ExpX = 160
  ExpY = 123
#------------------------------------------------------------------------------
# ● Menu Command Window
#------------------------------------------------------------------------------
  CommandX = 0
  CommandY = 198
#------------------------------------------------------------------------------
# ● Gold Window
#------------------------------------------------------------------------------
  GoldX = 160
  GoldY = 198
#------------------------------------------------------------------------------
# ● Variable 1 Window
#------------------------------------------------------------------------------
  Var1X = 0
  Var1Y = 246
#------------------------------------------------------------------------------
# ● Variable 2 Window
#------------------------------------------------------------------------------
  Var2X = 160
  Var2Y = 246
#------------------------------------------------------------------------------
# ● Variable 3 Window
#------------------------------------------------------------------------------
  Var3X = 0
  Var3Y = 294
#------------------------------------------------------------------------------
# ● Variable 4 Window
#------------------------------------------------------------------------------
  Var4X = 160
  Var4Y = 294
#------------------------------------------------------------------------------
# ● Mapname Window
#------------------------------------------------------------------------------
  MapX = 0
  MapY = 342
#------------------------------------------------------------------------------
# ● States Window
#------------------------------------------------------------------------------
  StateX = 160
  StateY = 342
#------------------------------------------------------------------------------
# ● Profile Window
#------------------------------------------------------------------------------
  ProX = 320
  ProY = 0
#------------------------------------------------------------------------------
# ● Text Alignment
#------------------------------------------------------------------------------
  ALIGNMENT = 2
end


#==============================================================================
#   KIT TESTING GROUNDS, OH NO!
#==============================================================================
class Menu_Portrait

  #--------------------------------------------------------------------------
  # ● Create Sprites
  #--------------------------------------------------------------------------
  def create_sprites
    create_character
  end

  #--------------------------------------------------------------------------
  # ● Create Character
  #--------------------------------------------------------------------------
  def create_character
    @character_float = [0, 0, 0]
    @character = Sprite.new
    @character.bitmap = Cache.title1("Character")
    @character.ox = @character.bitmap.width / 2
    @character.oy = @character.bitmap.height / 2
    fy = CHARACTER_FLOAT_EFFECT ? CHARACTER_FLOAT_RANGE : 0
    @character_org = [CHARACTER_POSITION[0] + @character.ox,
                      CHARACTER_POSITION[1] + @character.oy + fy]
    @character.x = @character_org[0]
    @character.y = @character_org[1]
    @character.z = 3
    @character.opacity = 0
    @char_zoom_speed = [0, 0, 0]

    @character2 = Sprite.new
    @character2.bitmap = Cache.title1("Character")
    @character2.ox = @character.ox
    @character2.oy = @character.oy
    @character2.x = @character_org[0]
    @character2.y = @character_org[1]
    @character2.z = @character.z - 1
    @character2.blend_type = 1
    @character2.opacity = 0
    @character2.visible = CHARACTER_AURA_EFFECT
    @character2.zoom_x = 1.0
    @character2.zoom_y = @character2.zoom_x
  end


  #--------------------------------------------------------------------------
  # ● Update Character
  #--------------------------------------------------------------------------
  def update_character
    return if @character == nil
    update_character_float_effect
    if !$showedtransition
      @character.opacity += 5
    else
      @character.opacity += 25
    end
    update_character_aura_effect
  end

  #--------------------------------------------------------------------------
  # ● Update Character Aura Effect
  #--------------------------------------------------------------------------
  def update_character_aura_effect
    return if !CHARACTER_AURA_EFFECT
    @character2.opacity -= 1
    @char_zoom_speed[0] += 1
    case @char_zoom_speed[0]
    when 1..120
      @char_zoom_speed[2] += 0.001
    when 121..240
      @char_zoom_speed[2] -= 0.001
    else
      @char_zoom_speed[0] = 0
      @char_zoom_speed[2] = 0
      @character2.zoom_x = 1.00
      @character2.zoom_y = 1.00
      @character2.opacity = 255
      @character2.y = @character.y
    end
    @character2.zoom_x = 1.00 + @char_zoom_speed[2]
    @character2.zoom_y = @character2.zoom_x
  end

  #--------------------------------------------------------------------------
  # ● Update Character Float Effect
  #--------------------------------------------------------------------------
  def update_character_float_effect
    return if !CHARACTER_FLOAT_EFFECT
    @character_float[0] += 1
    return if @character_float[0] < CHARACTER_FLOAT_SPEED
    @character_float[0] = 0
    @character_float[1] += 1
    case @character_float[1]
    when 0..CHARACTER_FLOAT_RANGE
      @character_float[2] -= 1
    when CHARACTER_FLOAT_RANGE..(CHARACTER_FLOAT_RANGE * 2) - 1
      @character_float[2] += 1
    else
      @character_float = [0, 0, 0]
    end
    @character.y = @character_org[1] + @character_float[2]
  end

  #--------------------------------------------------------------------------
  # ● Update Float Effect
  #--------------------------------------------------------------------------
  def update_float_effect
    @float[2] += 1
    return if @float[2] < 5
    @float[2] = 0
    @float[1] += 1
    case @float[1]
    when 1..5
      @float[0] -= 1
    when 6..15
      @float[0] += 1
    when 16..20
      @float[0] -= 1
    else
      @float[0] = 0
      @float[1] = 0
    end
  end

  #--------------------------------------------------------------------------
  # ● Dispose Character
  #--------------------------------------------------------------------------
  def dispose_character
    @character.bitmap.dispose
    @character.dispose
    @character2.bitmap.dispose
    @character2.dispose
  end

end

#==============================================================================
#                                Menu Items
#------------------------------------------------------------------------------
# ▼ Scene_Menu
#------------------------------------------------------------------------------
# - This class performs the menu screen processing.
#------------------------------------------------------------------------------
class Scene_Menu < Scene_MenuBase
#------------------------------------------------------------------------------
# ● Start MOD Processing
#------------------------------------------------------------------------------
  def start
    super
    create_background
    create_logo_window
    create_health_window
    create_mana_window
    create_level_window
    create_exp_window
    create_command_window
    create_var1_window
    create_var2_window
    create_var3_window
    create_var4_window
    create_map_window
    create_gold_window
    create_state_window
    create_pro_window
  end
#------------------------------------------------------------------------------
# ● Gold Window MOD
#------------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.x = (MOD::GoldX)
    @gold_window.y = (MOD::GoldY)
    @gold_window.windowskin = Cache.system(MOD::WINDOW)
    @gold_window.width = 160
    @gold_window.height = 48
  end
#------------------------------------------------------------------------------
# ● Logo Window MOD
#------------------------------------------------------------------------------
  def create_logo_window
    @logo_window = Window_Logo.new((MOD::LogoX), (MOD::LogoY))
    @logo_window.x = (MOD::LogoX)
    @logo_window.y = (MOD::LogoY)
    @logo_window.windowskin = Cache.system(MOD::WINDOW)
  end
#------------------------------------------------------------------------------
# ● Health Window MOD
#------------------------------------------------------------------------------
  def create_health_window
    @health_window = Window_Health.new((MOD::HealthX), (MOD::HealthY))
    @health_window.x = (MOD::HealthX)
    @health_window.y = (MOD::HealthY)
    @health_window.windowskin = Cache.system(MOD::WINDOW)
  end
#------------------------------------------------------------------------------
# ● Mana Window MOD
#------------------------------------------------------------------------------
  def create_mana_window
    @mana_window = Window_Mana.new((MOD::ManaX), (MOD::ManaY))
    @mana_window.x = (MOD::ManaX)
    @mana_window.y = (MOD::ManaY)
    @mana_window.windowskin = Cache.system(MOD::WINDOW)
  end
#------------------------------------------------------------------------------
# ● Level Window MOD
#------------------------------------------------------------------------------
  def create_level_window
    @level_window = Window_Level.new((MOD::LevelX), (MOD::LevelY))
    @level_window.x = (MOD::LevelX)
    @level_window.y = (MOD::LevelY)
    @level_window.windowskin = Cache.system(MOD::WINDOW)
  end
#------------------------------------------------------------------------------
# ● Experience Window MOD
#------------------------------------------------------------------------------
  def create_exp_window
    @exp_window = Window_Exp.new((MOD::ExpX), (MOD::ExpY))
    @exp_window.x = (MOD::ExpX)
    @exp_window.y = (MOD::ExpY)
    @exp_window.windowskin = Cache.system(MOD::WINDOW)
  end
#------------------------------------------------------------------------------
# ● Command Window MOD
#------------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,    method(:command_item))
    @command_window.set_handler(:skill,   method(:command_skill))
    @command_window.set_handler(:equip,   method(:command_equip))
    @command_window.set_handler(:status,  method(:command_status))
    @command_window.set_handler(:save,    method(:command_save))
    @command_window.set_handler(:end,     method(:command_end))
    @command_window.set_handler(:cancel,  method(:return_scene))
    @command_window.x = (MOD::CommandX)
    @command_window.y = (MOD::CommandY)
    @command_window.width = 160
  end
end
#------------------------------------------------------------------------------
# ● [Scene_Item]
#------------------------------------------------------------------------------
def command_item
  @actor = $game_party.members[0]
  SceneManager.call(Scene_Item)
end
#------------------------------------------------------------------------------
# ● [Scene_Skill]
#------------------------------------------------------------------------------
def command_skill
  @actor = $game_party.members[0]
  SceneManager.call(Scene_Skill)
end
#------------------------------------------------------------------------------
# ● [Scene_Equip]
#------------------------------------------------------------------------------
def command_equip
  @actor = $game_party.members[0]
  SceneManager.call(Scene_Equip)
end
#------------------------------------------------------------------------------
# ● [Scene_Status]
#------------------------------------------------------------------------------
def command_status
  @actor = $game_party.members[0]
  SceneManager.call(Scene_Status)
end
#------------------------------------------------------------------------------
# ● [Scene_Save]
#------------------------------------------------------------------------------
def command_save
  @actor = $game_party.members[0]
  SceneManager.call(Scene_Save)
end
#------------------------------------------------------------------------------
# ● [Scene_End]
#------------------------------------------------------------------------------
def command_end
  @actor = $game_party.members[0]
  SceneManager.call(Scene_End)
end
#------------------------------------------------------------------------------
# ● Variable 1 Window MOD
#------------------------------------------------------------------------------
def create_var1_window
  @var1_window = Window_Var1.new((MOD::Var1X), (MOD::Var1Y))
  @var1_window.x = (MOD::Var1X)
  @var1_window.y = (MOD::Var1Y)
  @var1_window.windowskin = Cache.system(MOD::WINDOW)
end
#------------------------------------------------------------------------------
# ● Variable 2 Window MOD
#------------------------------------------------------------------------------
def create_var2_window
  @var2_window = Window_Var2.new((MOD::Var2X), (MOD::Var2Y))
  @var2_window.x = (MOD::Var2X)
  @var2_window.y = (MOD::Var2Y)
  @var2_window.windowskin = Cache.system(MOD::WINDOW)
end
#------------------------------------------------------------------------------
# ● Variable 3 Window MOD
#------------------------------------------------------------------------------
def create_var3_window
  @var3_window = Window_Var3.new((MOD::Var3X), (MOD::Var3Y))
  @var3_window.x = (MOD::Var3X)
  @var3_window.y = (MOD::Var3Y)
  @var3_window.windowskin = Cache.system(MOD::WINDOW)
end
#------------------------------------------------------------------------------
# ● Variable 4 Window MOD
#------------------------------------------------------------------------------
def create_var4_window
  @var4_window = Window_Var4.new((MOD::Var4X), (MOD::Var4Y))
  @var4_window.x = (MOD::Var4X)
  @var4_window.y = (MOD::Var4Y)
  @var4_window.windowskin = Cache.system(MOD::WINDOW)
end
#------------------------------------------------------------------------------
# ● Mapname Window MOD
#------------------------------------------------------------------------------
def create_map_window
  @map_window = Window_Map.new((MOD::MapX), (MOD::MapY))
  @map_window.x = (MOD::MapX)
  @map_window.y = (MOD::MapY)
  @map_window.windowskin = Cache.system(MOD::WINDOW)
end
#------------------------------------------------------------------------------
# ● States Window MOD
#------------------------------------------------------------------------------
def create_state_window
  @state_window = Window_State.new((MOD::StateX), (MOD::StateY))
  @state_window.x = (MOD::StateX)
  @state_window.y = (MOD::StateY)
  @state_window.windowskin = Cache.system(MOD::WINDOW)
end
#------------------------------------------------------------------------------
# ● Profile Window MOD
#------------------------------------------------------------------------------
def create_pro_window
  @pro_window = Window_Pro.new((MOD::ProX), (MOD::ProY))
  @pro_window.x = (MOD::ProX)
  @pro_window.y = (MOD::ProY)
  @pro_window.windowskin = Cache.system(MOD::WINDOW)
end
#==============================================================================
# ▼ Window_Gold
#------------------------------------------------------------------------------
# This window displays the available gold.
#==============================================================================
class Window_Gold < Window_Base
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_currency_value(value, currency_unit, 4, 2, contents.width - 25)
  end
  #--------------------------------------------------------------------------
  # ● Get Party Gold
  #--------------------------------------------------------------------------
  def value
    $game_party.gold
  end
  #--------------------------------------------------------------------------
  # ● Get Currency Unit
  #--------------------------------------------------------------------------
  def currency_unit
  #--------------------------------------------------------------------------
  # ● Gold Icon
  #--------------------------------------------------------------------------
    draw_icon(361, contents.width - 23, -1, true)
    "Gold"
  end
  #--------------------------------------------------------------------------
  # ● Open Window
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end
#==============================================================================
# ▼ Window Logo
#------------------------------------------------------------------------------
# - This windows displays Main Menu Logo.
#------------------------------------------------------------------------------
class Window_Logo < Window_Base
  def initialize(x, y)
    super(x, y, 320, 48)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(system_color)
    draw_text(0, 0, 300, line_height, "Testing some changes to the menu!", 1)
  end
end
#==============================================================================
# ▼ Window Health
#------------------------------------------------------------------------------
# - This windows displays Health.
#------------------------------------------------------------------------------
class Window_Health < Window_Base
  def initialize(x, y)
    super(x, y, 160, 75)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(0, 0, 250, line_height, "Health Condition")
    draw_actor_hp(@actor, 0 , 20)
  end
#------------------------------------------------------------------------------
# ● Draw HP
#------------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    change_color(system_color)
    draw_text(5, 20, 100, line_height, "Health")
    change_color(normal_color)
    draw_text(5, 20, 116, line_height, actor.hp, 2)
  end
end
#==============================================================================
# ▼ Window Mana
#------------------------------------------------------------------------------
# - This windows displays Mana.
#------------------------------------------------------------------------------
class Window_Mana < Window_Base
  def initialize(x, y)
    super(x, y, 160, 75)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(0, 0, 250, line_height, "Mana Condition")
    draw_actor_mp(@actor, 0 , 20)
  end
#------------------------------------------------------------------------------
# ● Draw MP
#------------------------------------------------------------------------------
  def draw_actor_mp(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    change_color(system_color)
    draw_text(5, 20, 100, line_height, "Mana")
    change_color(normal_color)
    draw_text(5, 20, 116, line_height, actor.mp, 2)
  end
end
#==============================================================================
# ▼ Window Level
#------------------------------------------------------------------------------
# - This windows displays Level.
#------------------------------------------------------------------------------
class Window_Level < Window_Base
  def initialize(x, y)
    super(x, y, 160, 75)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(0, 0, 250, line_height, "Current Level")
    draw_actor_level(@actor, 0 , 20)
  end
#------------------------------------------------------------------------------
# ● Draw Level
#------------------------------------------------------------------------------
  def draw_actor_level(actor, x, y, width = 124)
    draw_gauge(x, y, width, actor.lvl_rate, text_color(10), text_color(2))
    change_color(system_color)
    draw_text(5, 20, 100, line_height, Vocab::level_a)
    change_color(normal_color)
    draw_text(5, 20, 116, line_height, actor.level, 2)
  end
end
#==============================================================================
# ▼ Window Exp
#------------------------------------------------------------------------------
# - This windows displays Experience.
#------------------------------------------------------------------------------
class Window_Exp < Window_Base
  def initialize(x, y)
    super(x, y, 160, 75)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(0, 0, 250, line_height, "Experience")
    if @actor.max_level?
      draw_actor_maxlevel(@actor, 0, 20)
    else
      draw_actor_nxtlevel(@actor, 0, 20)
    end
  end
#------------------------------------------------------------------------------
# ● Draw Exp
#------------------------------------------------------------------------------
  def draw_actor_nxtlevel(actor, x, y, width = 124, rate = actor.exp_rate)
    draw_gauge(x, y, width, actor.exp_rate, text_color(28), text_color(29))
    next_level = actor.next_level_exp - actor.exp
    change_color(system_color)
    draw_text(5, 20, 100, line_height, "Exp")
    change_color(normal_color)
    draw_text(5, 20, 116, line_height, next_level, 2)
  end
  def draw_actor_maxlevel(actor, x, y, width = 124, rate = 1.0)
    draw_gauge(0, 20, 124, rate, text_color(28), text_color(29))
    change_color(system_color)
    draw_text(5, 20, 116, line_height, "Max-Out")
  end
end
#==============================================================================
#  ▼ Window Variable 1
#------------------------------------------------------------------------------
#  - This windows displays Varialbe ID No.1
#------------------------------------------------------------------------------
class Window_Var1 < Window_Base
  def initialize(x, y)
    super(x, y, 160, 48)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(25, 0, 250, line_height, "Doot doot!",)
    change_color(system_color)
    draw_text(x, 0, contents_width, line_height, "#{$game_variables[1]}", 2)
    draw_icon(187, 0, -1, true)
  end
end
#==============================================================================
#  ▼ Window Variable 2
#------------------------------------------------------------------------------
#  - This windows displays Varialbe ID No.2
#------------------------------------------------------------------------------
class Window_Var2 < Window_Base
  def initialize(x, y)
    super(x, y, 160, 48)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(25, 0, 250, line_height, "Shit bricks")
    change_color(system_color)
    draw_text(0, 0, contents_width, line_height, "#{$game_variables[2]}", 2)
    draw_icon(188, 0, -1, true)
  end
end
#==============================================================================
#  ▼ Window Variable 3
#------------------------------------------------------------------------------
#  - This windows displays Varialbe ID No.3
#------------------------------------------------------------------------------
class Window_Var3 < Window_Base
  def initialize(x, y)
    super(x, y, 160, 48)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(20, 0, 250, line_height, "Testing")
    change_color(system_color)
    draw_text(x, 0, contents_width, line_height, "#{$game_variables[3]}", 2)
    draw_icon(189, 0, -1, true)
  end
end
#==============================================================================
#  ▼ Window Variable 4
#------------------------------------------------------------------------------
#  - This windows displays Varialbe ID No.4
#------------------------------------------------------------------------------
class Window_Var4 < Window_Base
  def initialize(x, y)
    super(x, y, 160, 48)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(25, 0, 250, line_height, "Fake pants")
    change_color(system_color)
    draw_text(0, 0, contents_width, line_height, "#{$game_variables[4]}", 2)
    draw_icon(190, 0, -1, true)
  end
end
#==============================================================================
# ▼ Window Mapname
#------------------------------------------------------------------------------
# - This windows displays Map Name
#------------------------------------------------------------------------------
class Window_Map < Window_Base
  def initialize(x, y)
    super(x, y, 160, 74)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(hp_gauge_color1)
    draw_text(0, 0, 250, line_height, "Location:")
    change_color(system_color)
    draw_text(0, 20, 250, line_height, "#{$data_mapinfos[$game_map.map_id].name}")
    draw_icon(231, contents.width - 23, -1, true)
  end
end
#==============================================================================
# ▼ Window State
#------------------------------------------------------------------------------
# - This windows displays States
#------------------------------------------------------------------------------
class Window_State < Window_Base
  def initialize(x, y)
    super(x, y, 160, 74)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    contents.fill_rect(0, 0, width, height, Font.default_out_color)
    change_color(tp_gauge_color1)
    draw_text(5, 0, width, line_height, "States:")
    draw_actor_icons(@actor, 5, 21, width = 96)
  end
end
#==============================================================================
# ▼ Window Profile
#------------------------------------------------------------------------------
# - This windows displays Biography.
#------------------------------------------------------------------------------
class Window_Pro < Window_Base
  def initialize(x, y)
    super(x, y, 224, 416)
    refresh
  end
#------------------------------------------------------------------------------
# - Refresh
#------------------------------------------------------------------------------
  def refresh
    self.contents.clear
    @actor = $game_party.members[0]
    change_color(system_color)
    draw_text(0, 0, width, line_height, "Character Identity Card:")
         # Actor Face Position
    contents.fill_rect(0, 25, 96, 96, Font.default_out_color)
    draw_actor_face(@actor, 0, 25)
         # Actor Sprite Position
    contents.fill_rect(105, 25, width, 96, Font.default_out_color)
    draw_actor_graphic(@actor, 151, 90)
         # Actor Name Position
    contents.fill_rect(0, 130, width, 44, Font.default_out_color)
    change_color(system_color)
    draw_text(5, 130, width, line_height, "Character Name:")
    draw_actor_name(@actor, 5, 150)
         # Actor Class Position
    contents.fill_rect(0, 183, width, 44, Font.default_out_color)
    change_color(system_color)
    draw_text(5, 185, width, line_height, "Character Profile:")
    draw_actor_class(@actor, 5, 204)
         # Actor Parameters Position
    contents.fill_rect(0, 236, width, height, Font.default_out_color)
    contents.font.size = 14
         #change_color(tp_gauge_color1)
    draw_text(5, 238, 200, line_height, "I DON'T NEED THESE, WOO!")
         #sprite.bitmap = Cache.picture("yellowgem")
         #draw_actor_param(@actor, 5, 258, 2)
         #draw_actor_param(@actor, 5, 278, 3)
         #draw_actor_param(@actor, 5, 298, 4)
         #draw_actor_param(@actor, 5, 318, 5)
         #draw_actor_param(@actor, 5, 338, 6)
         #draw_actor_param(@actor, 5, 358, 7)
  end
end

#==============================================================================
# ▼ Window Menu Commands
#------------------------------------------------------------------------------
# This window appears in main menu screen.
#------------------------------------------------------------------------------
class Window_MenuCommand < Window_Command
  def self.init_command_position
    @@last_command_symbol = nil
  end
#------------------------------------------------------------------------------
# - Object Initialization
#------------------------------------------------------------------------------
  def initialize
    super(0, 0)
    select_last
  end
#------------------------------------------------------------------------------
# ● Command Window Width
#------------------------------------------------------------------------------
  def window_width
    return 160
  end
#------------------------------------------------------------------------------
# ● Command Window Lines
#------------------------------------------------------------------------------
  def visible_line_number
    1
  end
#------------------------------------------------------------------------------
# - Command Item List
#------------------------------------------------------------------------------
  def make_command_list
    add_main_commands
    add_original_commands
  end
#------------------------------------------------------------------------------
# ● Menu Commands List
#------------------------------------------------------------------------------
  def add_main_commands
    add_command("Inventory", :item, main_commands_enabled)
    add_command("Magic",      :skill,  main_commands_enabled)
    add_command("Equipments", :equip,  main_commands_enabled)
    add_command("Status",     :status, main_commands_enabled)
    add_command("Save",       :save,   main_commands_enabled)
    add_command("Quit Game",  :end,    main_commands_enabled)
  end
#------------------------------------------------------------------------------
# - Enable Orgiginal Commands
#------------------------------------------------------------------------------
  def add_original_commands
  end
#------------------------------------------------------------------------------
# - Main Command Activation
#------------------------------------------------------------------------------
  def main_commands_enabled
    $game_party.exists
  end
#------------------------------------------------------------------------------
# - Formation: Activation/De-activation
#------------------------------------------------------------------------------
  def formation_enabled
    $game_party.members.size >= 2 && !$game_system.formation_disabled
  end
#------------------------------------------------------------------------------
# - Processing When OK Button Is Pressed
#------------------------------------------------------------------------------
  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
#------------------------------------------------------------------------------
# - Last Selection Position
#------------------------------------------------------------------------------
  def select_last
    select_symbol(@@last_command_symbol)
  end
end
#==============================================================================
# ■ End Of Script
#==============================================================================
