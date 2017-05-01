=begin
======================================
  Survival System v1.11 (formerly known as Needs System)
  Created by: Apellonyx
  Released: 2 April 2013
  Last Update: 5 April 2013
======================================
  Terms of Use:
    You are free to use this system however you wish, in commercial and non-
    commercial games alike. If you edit the script extensively, it is not
    necessary to credit me (since you clearly only used my code as a framework),
    but I would appreciate credit if it is used in its current form, or if only
    minor changes were made to the script.
======================================
  Support:
    While I am not wildly active, I usually log onto "rpgmakervxace.com" daily,
    so if you have any questions pertaining to the script, you can ask any
    questions there, in the topic in which this script was released. Just as a
    warning, though, I will not edit the script to make it compatible with any
    special menu systems, but I will try to fix bugs as they come up. If you
    find one, let me know, and I'll do my best to squash the thing.
======================================
  Changelog:
    v1.0: 2 April 2013 - Original version. Included food, water, rest, and life.
    v1.01: 3 April 2013 - Added configurable maximum values for food,
      water, and rest, and made the maximum for life a configurable value. The
      failsafe mentioned in v1.0's Instructions is no longer needed.
    v1.02: 3 April 2013 - Added support for a fully configurable "reverse logic"
      stat, as suggested by esrann.
    v1.10: 5 April 2013 - Complete rewrite using global variables rather than
      game variables and switches. All stats are now optional, configurable,
      and can be hidden from the menu.
    v1.11: 17 May 2013 - Fixed a major bug involving the use of float values.
      Floats should work just fine now without causing the game to crash or
      the script to just die randomly. Also added background opacity config.
======================================
  Requirements:
    There are no longer any requirements for this script. I'm working on a
    script that will allow the global variables to be changed through note
    calls, but it may be a minute for that.
======================================
  Description:
    This sets up a needs system, which includes food, water, and rest, all of
    which affect the main need, life. The 1.02 update also added a reverse logic
    stat for toxin or radiation handling. All five stats, along with their
    update rates, are handled by global variables, and can be changed at any
    time with a simple script call.
======================================
  Instructions:
    First, you're going to want to set up how you want the script to run. All of
    the options are in the first module of the script, named "Anyx." I don't
    recommend changing anything after that module unless you know what you are
    doing.
   
    Second, once you have all of your options set up, you can go about setting
    up the nourishment items. All you have to do is set it up in the database as
    you normally would, and then attach an effect that calls a common event.
    Inside the common event, use one of the following scripts call to change the
    appropriate variable. It's as simple as that.
   
    $survival_v[id] op value
    id = The stat you want to change. 1 is for life, 2 food, 3 water, 4 rest,
      and 5 toxin. Ids 6-10 are used to hold the stats' rates. 6 is for life, 7
      food, 8 water, 9 rest, and 10 toxin (setting any of these rates to 0 will
      disable updates for its stat, effectively pausing the system for that stat
      individually without pausing it for the others)
    op = The operator used to formulate the new value. += is used to add, -= is
      for subtraction, *= is for multiplication, /= is for division, and %= is
      for modulus. There are others, and they all work, but I don't imagine you
      would use them for this script, so I won't explain them here.
    value = The value you would like to alter the variable by. For example, if
      you are adding 10 to a variable, this would be 10.
     
    $survival_s[id] = value
    id = The stat you wish to enable or disable. 1 is for life, 2 food, 3 water,
      4 rest, 5 toxin. Ids 6-10 are used to hide the stat bars from the menu.
    value = true/false. Setting the value to true for ids 1-5 will enable the
      associated stat. Setting it to false will disable it completely. For ids
      6-10, setting the value to true will hide that stat from the menu, but
      still allow it to update (this can be customized using the LIFEHIDEVAL,
      FOODHIDEVAL, WATERHIDEVAL, RESTHIDEVAL, and TOXINHIDEVAL options in the
      Anyx module below. When the hide option is true, that stat will be hidden
      from the menu until the stat is below the (STAT)HIDEVAL's value, or above
      the TOXINHIDEVAL's value for the toxin stat). If false, the stat will be
      visible in the menu at all times.
   
    You no longer need to manually set the initial values for each variable, as
    this can be done through the script, but you do need to turn on the survival
    switch manually, or the script won't do anything.
======================================
=end
 
$imported = {} if $imported.nil?
$imported['Apellonyx-Survival'] = true
 
puts "Load: Survival System v1.10 by Apellonyx"
 
module Anyx
 
  WINXPOS       = 0 # X position of the survival window
  WINYPOS       = 320 # Y position of the survival window
  WINWIDTH      = 160 # Width of the survival window
  WINTEXT       = 20 # Text size used in the survival window (looks best at 20)
  WINOPACITY    = 255 # Opacity of the survival window
 
  SURVIVALSWITCH  = 1 # Game switch ID for enabling and disabling the system
  ONINBATTLE      = true # Whether the system will update during battle scenes
  DEATHATZERO     = true # If true, will cause a gameover when the life stat
                         # reaches 0
  DEATHFULLTOXIN  = true # If true, will cause a gameover when the toxin stat
                         # reaches its maximum value
 
  LIFEVOCAB       = "Life" # Vocab used for the life stat in the menu
  LIFEINIT        = 100 # Initial value of the life stat in new games
  LIFERATE        = 300 # Number of frames between life stat updates
  LIFEMAX         = 100 # Maximum value for the life bar in the menu
  LIFEEXC         = 100 # Maximum value for the life stat (can exceed LIFEMAX)
  LIFEENABLE      = true # If true, the life stat will be enabled
  LIFEHIDE        = true # If true, the life bar will be hidden from the menu
  LIFEHIDEVAL     = 100 # If LIFEHIDE is true, the life bar will appear when it
                        # falls below this value.
 
  FOODVOCAB       = "Food" # Vocab used for the food stat in the menu
  FOODINIT        = 100 # Initial value of the food stat in new games
  FOODRATE        = 1200 # Number of frames between food stat updates
  FOODMAX         = 100 # Maximum value for the food bar in the menu
  FOODEXC         = 110 # Maximum value for the food stat (can exceed FOODMAX)
  FOODMOD         = -1.0 # Value of the food stat's change each update; positive
                         # values will increase the stat over time, negative
                         # values decrease the stat over time, and 0 will cause
                         # no update to occur over time. Accepts float values.
  FOODENABLE      = true # If true, the food stat will be enabled
  FOODHIDE        = true # If true, the food bar will be hidden from the menu
  FOODHIDEVAL     = 100 # If FOODHIDE is true, the food bar will appear when it
                        # falls below this value.
 
  WATERVOCAB      = "Water" # Vocab used for the water stat in the menu
  WATERINIT       = 100 # Initial value of the water stat in new games
  WATERRATE       = 900 # Number of frames between water stat updates
  WATERMAX        = 100 # Maximum value for the water bar in the menu
  WATEREXC        = 110 # Maximum value for the water stat (can exceed WATERMAX)
  WATERMOD        = -1.0 # Value of the water stat's change each update; positive
                         # values will increase the stat over time, negative
                         # values decrease the stat over time, and 0 will cause
                         # no update to occur over time. Accepts float values.
  WATERENABLE     = true # If true, the water stat will be enabled
  WATERHIDE       = true # If true, the water bar will be hidden from the menu
  WATERHIDEVAL    = 100 # If WATERHIDE is true, the water bar will appear when
                        # it falls below this value.
 
  RESTVOCAB       = "Rest" # Vocab used for the rest stat in the menu
  RESTINIT        = 100 # Initial value of the rest stat in new games
  RESTRATE        = 1500 # Number of frames between rest stat updates
  RESTMAX         = 100 # Maximum value for the rest bar in the menu
  RESTEXC         = 110 # Maximum value for the rest stat (can exceed RESTMAX)
  RESTMOD         = -1.0 # Value of the rest stat's change each update; positive
                         # values will increase the stat over time, negative
                         # values decrease the stat over time, and 0 will cause
                         # no update to occur over time. Accepts float values.
  RESTENABLE      = true # If true, the rest stat will be enabled
  RESTHIDE        = true # If true, the rest bar will be hidden from the menu
  RESTHIDEVAL     = 100 # If RESTHIDE is true, the rest bar will appear when it
                        # falls below this value.
 
  TOXINVOCAB      = "Toxin" # Vocab used for the toxin stat in the menu
  TOXININIT       = 0 # Initial value of the toxin stat in new games
  TOXINRATE       = 100 # Number of frames between toxin stat updates
  TOXINMAX        = 1000 # Maximum value for the toxin stat and toxin bar
  TOXINMOD        = 0.1 # Value of the toxin stat's change each update; positive
                        # values will increase the stat over time, negative
                        # values decrease the stat over time, and 0 will cause
                        # no update to occur over time. Accepts float values.
  TOXINENABLE     = true # If true, the toxin stat will be enabled
  TOXINHIDE       = true # If true, the toxin bar will be hidden from the menu
  TOXINHIDEVAL    = 0 # If TOXINHIDE is true, the toxin bar will appear when it
                      # rises above this value.
 
  LIFECOLORL      = 17 # Color ID of the left side of the life bar
  LIFECOLORR      = 6 # Color ID of the right side of the life bar
  FOODCOLORL      = 3 # Color ID of the left side of the food bar
  FOODCOLORR      = 24 # Color ID of the right side of the food bar
  WATERCOLORL     = 16 # Color ID of the left side of the water bar
  WATERCOLORR     = 4 # Color ID of the right side of the water bar
  RESTCOLORL      = 31 # Color ID of the left side of the rest bar
  RESTCOLORR      = 13 # Color ID of the right side of the rest bar
  TOXINCOLORL     = 10 # Color ID of the left side of the toxin bar
  TOXINCOLORR     = 2 # Color ID of the right side of the toxin bar
 
  EXCCOLOR        = 11 # Color ID of text for stat values over 100%
  SATCOLOR        = 24 # Color ID of text for stat values between 76 and 100%
  AVECOLOR        = 17 # Color ID of text for stat values between 51 and 75%
  LOWCOLOR        = 14 # Color ID of text for stat values between 26 and 50%
  DANCOLOR        = 20 # Color ID of text for stat values between 1 and 25%
  DEPCOLOR        = 18 # Color ID of text for stat values of 0%
 
################################################################################
################################################################################
###                                                                          ###
###  I don't recommend editing anything past this line unless you know what  ###
###   you are doing. If you do know what you're doing, however, go for it!   ###
###                                                                          ###
################################################################################
################################################################################
 
  def self.create_survival_commands
    $survival_v       =   Survival_Variables.new
    $survival_s       =   Survival_Switches.new
    $survival_v[1]    =   LIFEINIT
    $survival_v[6]    =   LIFERATE
    $survival_s[1]    =   LIFEENABLE
    $survival_s[6]    =   LIFEHIDE
    $survival_v[2]    =   FOODINIT
    $survival_v[7]    =   FOODRATE
    $survival_s[2]    =   FOODENABLE
    $survival_s[7]    =   FOODHIDE
    $survival_v[3]    =   WATERINIT
    $survival_v[8]    =   WATERRATE
    $survival_s[3]    =   WATERENABLE
    $survival_s[8]    =   WATERHIDE
    $survival_v[4]    =   RESTINIT
    $survival_v[9]    =   RESTRATE
    $survival_s[4]    =   RESTENABLE
    $survival_s[9]    =   RESTHIDE
    $survival_v[5]    =   TOXININIT
    $survival_v[10]   =   TOXINRATE
    $survival_s[5]    =   TOXINENABLE
    $survival_s[10]   =   TOXINHIDE
  end # def self.create_survival_commands
 
  class Survival_Variables
    def initialize
      @data = []
    end # def initialize
    def [](variable_id)
      @data[variable_id] || 0
    end # def [](variable_id)
    def []=(variable_id, value)
      @data[variable_id] = value
      on_change
    end # def []=(variable_id, value)
    def on_change
      $game_map.need_refresh = true
    end # def on_change
  end # class Survival_Variables
 
  class Survival_Switches
    def initialize
      @data = []
    end # def initialize
    def [](switch_id)
      @data[switch_id] || false
    end # def [](switch_id)
    def []=(switch_id, value)
      @data[switch_id] = value
      on_change
    end # def []=(switch_id, value)
    def on_change
      $game_map.need_refresh = true
    end # def on_change
  end # class Survival_Switches
 
  def self.update
    if $game_switches[SURVIVALSWITCH] == true
      if $survival_s[1] == true
        if $survival_v[6] > 0
          if Graphics.frame_count % $survival_v[6] == 0
            Anyx.life_update
          end # if Graphics.frame_count % $survival_v[6] == 0
        end # if $survival_v[6] > 0
      end # if $survival_s[1] == true
      if $survival_s[2] == true
        if $survival_v[7] > 0
          if Graphics.frame_count % $survival_v[7] == 0
            if $survival_v[2] < FOODEXC
              $survival_v[2] += FOODMOD if $survival_v[2] > 0
            end
          end # if Graphics.frame_count % $survival_v[7] == 0
        end # if $survival_v[7] > 0
      end # if $survival_s[1] == true
      if $survival_s[3] == true
        if $survival_v[8] > 0
          if Graphics.frame_count % $survival_v[8] == 0
            if $survival_v[3] < WATEREXC
              $survival_v[3] += WATERMOD if $survival_v[3] > 0
            end
          end # if Graphics.frame_count % $survival_v[8] == 0
        end # if $survival_v[8] > 0
      end # if $survival_s[3] == true
      if $survival_s[4] == true
        if $survival_v[9] > 0
          if Graphics.frame_count % $survival_v[9] == 0
            if $survival_v[4] < RESTEXC
              $survival_v[4] += RESTMOD if $survival_v[4] > 0
            end
          end # if Graphics.frame_count % $survival_v[9] == 0
        end # if $survival_v[9] > 0
      end # if $survival_s[4] == true
      if $survival_s[5] == true
        if $survival_v[10] > 0
          if Graphics.frame_count % $survival_v[10] == 0
            if $survival_v[5] < TOXINMAX
              $survival_v[5] += TOXINMOD if $survival_v[5] > 0
            end
          end # if Graphics.frame_count % $survival_v[10] == 0
        end # if $survival_v[10] > 0
      end # if $survival_s[5] == true
      $survival_v[1] = 0 if $survival_v[1] < 0
      $survival_v[2] = 0 if $survival_v[2] < 0
      $survival_v[3] = 0 if $survival_v[3] < 0
      $survival_v[4] = 0 if $survival_v[4] < 0
      $survival_v[5] = 0 if $survival_v[5] < 0
      $survival_v[1] = LIFEEXC if $survival_v[1] > LIFEEXC
      $survival_v[2] = FOODEXC if $survival_v[2] > FOODEXC
      $survival_v[3] = WATEREXC if $survival_v[3] > WATEREXC
      $survival_v[4] = RESTEXC if $survival_v[4] > RESTEXC
      $survival_v[5] = TOXINMAX if $survival_v[5] > TOXINMAX
      if $survival_v[1] <= 0
        SceneManager.call(Scene_Gameover) if DEATHATZERO
      end # if $survival_v[1] <= 0
      if $survival_v[5] >= TOXINMAX
        SceneManager.call(Scene_Gameover) if DEATHFULLTOXIN
      end # if $survival_v[5] >= TOXINMAX
    end # if $game_switches[SURVIVALSWITCH] == true
  end # def update
 
  def self.life_update
    if $survival_s[2] == true
      food_25 = FOODMAX / 4
      food_26 = food_25 + 0.001
      food_50 = food_25 * 2
      food_51 = food_50 + 0.001
      food_75 = food_25 * 3
      food_76 = food_75 + 0.001
      food_mod = -0.3 if 0 >= $survival_v[2]
      food_mod = -0.2 if (1..food_25) === $survival_v[2]
      food_mod = -0.1 if (food_26..food_50) === $survival_v[2]
      food_mod =  0.0 if (food_51..food_75) === $survival_v[2]
      food_mod =  0.1 if (food_76..FOODMAX) === $survival_v[2]
      food_mod =  0.2 if FOODMAX < $survival_v[2]
    else
      food_mod = 0
    end # if $survival_s[2] == true
    if $survival_s[3] == true
      water_25 = WATERMAX / 4
      water_26 = water_25 + 0.001
      water_50 = water_25 * 2
      water_51 = water_50 + 0.001
      water_75 = water_25 * 3
      water_76 = water_75 + 0.001
      water_mod = -0.3 if 0 >= $survival_v[3]
      water_mod = -0.2 if (1..water_25) === $survival_v[3]
      water_mod = -0.1 if (water_26..water_50) === $survival_v[3]
      water_mod =  0.0 if (water_51..water_75) === $survival_v[3]
      water_mod =  0.1 if (water_76..WATERMAX) === $survival_v[3]
      water_mod =  0.2 if WATERMAX < $survival_v[3]
    else
      water_mod = 0
    end # if $survival_s[4] == true
    if $survival_s[4] == true
      rest_25 = RESTMAX / 4
      rest_26 = rest_25 + 0.001
      rest_50 = rest_25 * 2
      rest_51 = rest_50 + 0.001
      rest_75 = rest_25 * 3
      rest_76 = rest_75 + 0.001
      rest_mod = -0.3 if 0 >= $survival_v[4]
      rest_mod = -0.2 if (1..rest_25) === $survival_v[4]
      rest_mod = -0.1 if (rest_26..rest_50) === $survival_v[4]
      rest_mod =  0.0 if (rest_51..rest_75) === $survival_v[4]
      rest_mod =  0.1 if (rest_76..RESTMAX) === $survival_v[4]
      rest_mod =  0.2 if RESTMAX < $survival_v[4]
    else
      rest_mod = 0
    end # if $survival_s[4] == true
    if $survival_s[5] == true
      toxin_25 = TOXINMAX / 4
      toxin_26 = toxin_25 + 0.001
      toxin_50 = toxin_25 * 2
      toxin_51 = toxin_50 + 0.001
      toxin_75 = toxin_25 * 3
      toxin_76 = toxin_75 + 0.001
      toxin_99 = TOXINMAX - 0.001
      toxin_mod =  0.1 if 0 >= $survival_v[5]
      toxin_mod =  0.0 if (1..toxin_25) === $survival_v[5]
      toxin_mod = -0.2 if (toxin_26..toxin_50) === $survival_v[5]
      toxin_mod = -0.4 if (toxin_51..toxin_75) === $survival_v[5]
      toxin_mod = -0.6 if (toxin_76..toxin_99) === $survival_v[5]
      toxin_mod = -0.8 if TOXINMAX <= $survival_v[5]
    else
      toxin_mod = 0.0
    end # if $survival_s[5] == true
    life_mod = food_mod + water_mod + rest_mod + toxin_mod
    $survival_v[1] += life_mod.round.to_i
  end # def life_update()
 
end # module Anyx
 
class Scene_Title
  alias survival_new_game command_new_game
  def command_new_game
    Anyx.create_survival_commands
    survival_new_game
  end # def command_new_game
end # class Scene_Title
 
class Scene_Map < Scene_Base
  alias survival_map_update update
  def update
    Anyx.update
    survival_map_update
  end # def update
end # class Scene_Base
 
class Scene_Battle < Scene_Base
  alias survival_battle_update update
  def update
    if Anyx::ONINBATTLE == true
      Anyx.update
      survival_battle_update
    end # if Anyx::ONINBATTLE == true
  end # def update
end # class Scene_Base
 
class Scene_Menu < Scene_MenuBase
  alias survival_menu_start start
  def start
    create_survival_window
    survival_menu_start
  end # def start
  def create_survival_window
    barcount = 0
    if $survival_s[1] == true
      barcount += 1 if $survival_s[6] == false || $survival_v[1] < Anyx::LIFEHIDEVAL
    end # if $survival_s[1] == true
    if $survival_s[2] == true
      barcount += 1 if $survival_s[7] == false || $survival_v[2] < Anyx::FOODHIDEVAL
    end # if $survival_s[2] == true
    if $survival_s[3] == true
      barcount += 1 if $survival_s[8] == false || $survival_v[3] < Anyx::WATERHIDEVAL
    end # if $survival_s[3] == true
    if $survival_s[4] == true
      barcount += 1 if $survival_s[9] == false || $survival_v[4] < Anyx::RESTHIDEVAL
    end # if $survival_s[4] == true
    if $survival_s[5] == true
      barcount += 1 if $survival_s[10] == false || $survival_v[5] > Anyx::TOXINHIDEVAL
    end # if $survival_s[5] == true
    @survival_window = Window_Survival.new
    @survival_window.contents.draw_text(0, 0, 500, 24, " Survival System") if barcount == 0
    barcount -= 1 if barcount >= 1
    survivalwinypos = Anyx::WINYPOS - (24 * barcount)
    @survival_window.x = Anyx::WINXPOS
    @survival_window.y = survivalwinypos
    @survival_window.opacity = Anyx::WINOPACITY
  end # def create_survival_window
end # class Scene_Menu < Scene_MenuBase
 
class Window_Survival < Window_Base
  def initialize
    winheight = 0
    if $survival_s[1] == true
      winheight += 1 if $survival_s[6] == false || $survival_v[1] < Anyx::LIFEHIDEVAL
    end # if $survival_s[1] == true
    if $survival_s[2] == true
      winheight += 1 if $survival_s[7] == false || $survival_v[2] < Anyx::FOODHIDEVAL
    end # if $survival_s[2] == true
    if $survival_s[3] == true
      winheight += 1 if $survival_s[8] == false || $survival_v[3] < Anyx::WATERHIDEVAL
    end # if $survival_s[3] == true
    if $survival_s[4] == true
      winheight += 1 if $survival_s[9] == false || $survival_v[4] < Anyx::RESTHIDEVAL
    end # if $survival_s[4] == true
    if $survival_s[5] == true
      winheight += 1 if $survival_s[10] == false || $survival_v[5] > Anyx::TOXINHIDEVAL
    end # if $survival_s[5] == true
    if winheight == 0
      winheight = 1
    end # if winheight == 0
    super(0, 0, Anyx::WINWIDTH, fitting_height(winheight))
    self.opacity = Anyx::WINOPACITY
    refresh
  end # def initialize
 
  def exc_color
    text_color(Anyx::EXCCOLOR)
  end # def exc_color
  def sat_color
    text_color(Anyx::SATCOLOR)
  end # def sat_color
  def ave_color
    text_color(Anyx::AVECOLOR)
  end # def ave_color
  def low_color
    text_color(Anyx::LOWCOLOR)
  end # def low_color
  def dan_color
    text_color(Anyx::DANCOLOR)
  end # def dan_color
  def dep_color
    text_color(Anyx::DEPCOLOR)
  end # def dep_color
 
  def refresh
    contents.clear
    contents.font.size = Anyx::WINTEXT
    lineheight = 0
    if $survival_s[1] == true
      if $survival_s[6] == false || $survival_v[1] < Anyx::LIFEHIDEVAL
        draw_life(0,0,lineheight)
        lineheight += 24
      end # if $survival_s[6] == false || $survival_v[1] < Anyx::LIFEHIDEVAL
    end # if $survival_s[1] == true
    if $survival_s[2] == true
      if $survival_s[7] == false || $survival_v[2] < Anyx::FOODHIDEVAL
        draw_food(0,0,lineheight)
        lineheight += 24
      end # if $survival_s[7] == false || $survival_v[2] < Anyx::FOODHIDEVAL
    end # if $survival_s[2] == true
    if $survival_s[3] == true
      if $survival_s[8] == false || $survival_v[3] < Anyx::WATERHIDEVAL
        draw_water(0,0,lineheight)
        lineheight += 24
      end # if $survival_s[8] == false || $survival_v[3] < Anyx::WATERHIDEVAL
    end # if $survival_s[3] == true
    if $survival_s[4] == true
      if $survival_s[9] == false || $survival_v[4] < Anyx::RESTHIDEVAL
        draw_rest(0,0,lineheight)
        lineheight += 24
      end # if $survival_s[9] == false || $survival_v[4] < Anyx::RESTHIDEVAL
    end # if $survival_s[4] == true
    if $survival_s[5] == true
      if $survival_s[10] == false || $survival_v[5] > Anyx::TOXINHIDEVAL
        draw_toxin(0,0,lineheight)
        lineheight += 24
      end # if $survival_s[10] == false || $survival_v[5] > Anyx::TOXINHIDEVAL
    end # if $survival_s[5] == true
  end # def refresh
 
  def draw_life(actor, x, y, width = Anyx::WINWIDTH - 22)
    life_25 = Anyx::LIFEMAX / 4
    life_26 = life_25 + 0.001
    life_50 = life_25 * 2
    life_51 = life_50 + 0.001
    life_75 = life_25 * 3
    life_76 = life_75 + 0.001
    life_99 = Anyx::LIFEMAX - 0.001
    life_color = dep_color if 1 > $survival_v[1]
    life_color = dan_color if (1..life_25) === $survival_v[1]
    life_color = low_color if (life_26..life_50) === $survival_v[1]
    life_color = ave_color if (life_51..life_75) === $survival_v[1]
    life_color = sat_color if (life_76..life_99) === $survival_v[1]
    life_color = exc_color if Anyx::LIFEMAX <= $survival_v[1]
    life_rate = $survival_v[1] / Anyx::LIFEMAX.to_f
    draw_gauge(x, y, width, life_rate, text_color(Anyx::LIFECOLORL), text_color(Anyx::LIFECOLORR))
    change_color(system_color)
    draw_text(x, y, 100, line_height, Anyx::LIFEVOCAB)
    draw_current_and_max_values(x, y, width, $survival_v[1].round.to_i, Anyx::LIFEMAX, life_color, life_color)
  end # def draw_life(actor, x, y, width = Anyx::WINWIDTH - 22)
  def draw_food(actor, x, y, width = Anyx::WINWIDTH - 22)
    food_25 = Anyx::FOODMAX / 4
    food_26 = food_25 + 0.001
    food_50 = food_25 * 2
    food_51 = food_50 + 0.001
    food_75 = food_25 * 3
    food_76 = food_75 + 0.001
    food_99 = Anyx::FOODMAX - 0.001
    food_color = dep_color if 1 > $survival_v[2]
    food_color = dan_color if (1..food_25) === $survival_v[2]
    food_color = low_color if (food_26..food_50) === $survival_v[2]
    food_color = ave_color if (food_51..food_75) === $survival_v[2]
    food_color = sat_color if (food_76..food_99) === $survival_v[2]
    food_color = exc_color if Anyx::FOODMAX <= $survival_v[2]
    food_rate = $survival_v[2] / Anyx::FOODMAX.to_f
    draw_gauge(x, y, width, food_rate, text_color(Anyx::FOODCOLORL), text_color(Anyx::FOODCOLORR))
    change_color(system_color)
    draw_text(x, y, 100, line_height, Anyx::FOODVOCAB)
    draw_current_and_max_values(x, y, width, $survival_v[2].round.to_i, Anyx::FOODMAX, food_color, food_color)
  end # def draw_food(actor, x, y, width = Anyx::WINWIDTH - 22)
  def draw_water(actor, x, y, width = Anyx::WINWIDTH - 22)
    water_25 = Anyx::WATERMAX / 4
    water_26 = water_25 + 0.001
    water_50 = water_25 * 2
    water_51 = water_50 + 0.001
    water_75 = water_25 * 3
    water_76 = water_75 + 0.001
    water_99 = Anyx::WATERMAX - 0.001
    water_color = dep_color if 1 > $survival_v[3]
    water_color = dan_color if (1..water_25) === $survival_v[3]
    water_color = low_color if (water_26..water_50) === $survival_v[3]
    water_color = ave_color if (water_51..water_75) === $survival_v[3]
    water_color = sat_color if (water_76..water_99) === $survival_v[3]
    water_color = exc_color if Anyx::WATERMAX <= $survival_v[3]
    water_rate = $survival_v[3] / Anyx::WATERMAX.to_f
    draw_gauge(x, y, width, water_rate, text_color(Anyx::WATERCOLORL), text_color(Anyx::WATERCOLORR))
    change_color(system_color)
    draw_text(x, y, 100, line_height, Anyx::WATERVOCAB)
    draw_current_and_max_values(x, y, width, $survival_v[3].round.to_i, Anyx::WATERMAX, water_color, water_color)
  end # def draw_water(actor, x, y, width = Anyx::WINWIDTH - 22)
  def draw_rest(actor, x, y, width = Anyx::WINWIDTH - 22)
    rest_25 = Anyx::WATERMAX / 4
    rest_26 = rest_25 + 0.001
    rest_50 = rest_25 * 2
    rest_51 = rest_50 + 0.001
    rest_75 = rest_25 * 3
    rest_76 = rest_75 + 0.001
    rest_99 = Anyx::RESTMAX - 0.001
    rest_color = dep_color if 1 > $survival_v[4]
    rest_color = dan_color if (1..rest_25) === $survival_v[4]
    rest_color = low_color if (rest_26..rest_50) === $survival_v[4]
    rest_color = ave_color if (rest_51..rest_75) === $survival_v[4]
    rest_color = sat_color if (rest_76..rest_99) === $survival_v[4]
    rest_color = exc_color if Anyx::RESTMAX <= $survival_v[4]
    rest_rate = $survival_v[4] / Anyx::RESTMAX.to_f
    draw_gauge(x, y, width, rest_rate, text_color(Anyx::RESTCOLORL), text_color(Anyx::RESTCOLORR))
    change_color(system_color)
    draw_text(x, y, 100, line_height, Anyx::RESTVOCAB)
    draw_current_and_max_values(x, y, width, $survival_v[4].round.to_i, Anyx::RESTMAX, rest_color, rest_color)
  end # def draw_rest(actor, x, y, width = Anyx::WINWIDTH - 22)
  def draw_toxin(actor, x, y, width = Anyx::WINWIDTH - 22)
    toxin_25 = Anyx::TOXINMAX / 4
    toxin_26 = toxin_25 + 0.001
    toxin_50 = toxin_25 * 2
    toxin_51 = toxin_50 + 0.001
    toxin_75 = toxin_25 * 3
    toxin_76 = toxin_75 + 0.001
    toxin_99 = Anyx::TOXINMAX - 0.001
    toxin_color = exc_color if 1 > $survival_v[5]
    toxin_color = sat_color if (1..toxin_25) === $survival_v[5]
    toxin_color = ave_color if (toxin_26..toxin_50) === $survival_v[5]
    toxin_color = low_color if (toxin_51..toxin_75) === $survival_v[5]
    toxin_color = dan_color if (toxin_76..toxin_99) === $survival_v[5]
    toxin_color = dep_color if Anyx::TOXINMAX <= $survival_v[5]
    toxin_rate = $survival_v[5] / Anyx::TOXINMAX.to_f
    draw_gauge(x, y, width, toxin_rate, text_color(Anyx::TOXINCOLORL), text_color(Anyx::TOXINCOLORR))
    change_color(system_color)
    draw_text(x, y, 100, line_height, Anyx::TOXINVOCAB)
    draw_current_and_max_values(x, y, width, $survival_v[5].round.to_i, Anyx::TOXINMAX, toxin_color, toxin_color)
  end # def draw_toxin(actor, x, y, width = Anyx::WINWIDTH - 22)
end # class
 
module DataManager
  def self.make_save_contents
    contents = {}
    contents[:system]        = $game_system
    contents[:timer]         = $game_timer
    contents[:message]       = $game_message
    contents[:switches]      = $game_switches
    contents[:variables]     = $game_variables
    contents[:self_switches] = $game_self_switches
    contents[:actors]        = $game_actors
    contents[:party]         = $game_party
    contents[:troop]         = $game_troop
    contents[:map]           = $game_map
    contents[:player]        = $game_player
    contents[:anyx_ss]       = $survival_s
    contents[:anyx_sv]       = $survival_v
    contents
  end # self.make_save_contents
  def self.extract_save_contents(contents)
    $game_system        = contents[:system]
    $game_timer         = contents[:timer]
    $game_message       = contents[:message]
    $game_switches      = contents[:switches]
    $game_variables     = contents[:variables]
    $game_self_switches = contents[:self_switches]
    $game_actors        = contents[:actors]
    $game_party         = contents[:party]
    $game_troop         = contents[:troop]
    $game_map           = contents[:map]
    $game_player        = contents[:player]
    $survival_s         = contents[:anyx_ss]
    $survival_v         = contents[:anyx_sv]
  end # self.extract_save_contents(contents)
end # module DataManager