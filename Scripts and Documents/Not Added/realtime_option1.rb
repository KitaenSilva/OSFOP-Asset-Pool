=begin =========================================================================
Dekita's                                                                   v1.1
                          ★ Pokémon RealTime Effects™ ★
 
================================================================================
 Script Information:
====================
 This script replicates the time system from pokemon,
 e.g in game time is determined by real life time.
 
 This script enables screen tint changes according to real time,
 not only that is can change weather effects, $game_switches, $game_variables,
 trigger common events and even your own custom "time" effects.
 You can set up different seasons (as many as you want)
 You can give each month its own unique season if you wish, turning on
 different swicthes and controling different variables on a month to month
 rotation.
 
 now you can simply control a switch / a variable / the weather / Screen Tint
 and whatever else you can code in realtime with minimal effort.
 
 COMPATIBLE WITH :
 Khas Awesome Light Effects,(change advanced lighting effects using real time)
 MOG Weather EX, (change mog weather effects using real time)
 
 AND
 
 other features will be available with the use of other pokemon style scripts
 e.g Capture add-on : Pokeball Effects ^_^
 
================================================================================
 ★☆★☆★☆★☆★☆★☆★☆★ TERMS AND CONDITIONS: ☆★☆★☆★☆★☆★☆★☆★☆★☆
================================================================================
 1. You must give credit to "Dekita"
 2. You are NOT allowed to repost this script.(or modified versions)
 3. You are NOT allowed to convert this script.(into other game engines e.g RGSS2)
 4. You are NOT allowed to use this script for Commercial games.
 5. ENJOY!
 
"FINE PRINT"
By using this script you hereby agree to the above terms and conditions,
 if any violation of the above terms occurs "legal action" may be taken.
Not understanding the above terms and conditions does NOT mean that
 they do not apply to you.
If you wish to discuss the terms and conditions in further detail you can
contact me at http://dekitarpg.wordpress.com/ or DekitaRPG@gmail.com
 
================================================================================
 History:
=========
 D /M /Y
 01/01/2o12 - fixed effects triggering too often.
 23/12/2o12 - finished,
 15/12/2o12 - started,
 
================================================================================
 Credit and Thanks to :
=======================
 Tsukihime - for helping me solve my menu problem :D
 
================================================================================
 Known Bugs:
============
 N/A
 
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 If a new bug is found please contact me at
 http://dekitarpg.wordpress.com/
 
================================================================================
 INSTRUCTIONS:
==============
 Place this script UNDER "▼ Materials" and ABOVE "▼ Main" in your script editor.
 
================================================================================
 NoteTags:
==========
 
 <no tint>
 put the above notetag into map noteboxes for maps that do not get tinted
 by real time, this would be buildings and things of that nature.
 
 <no weather>
 put this in map noteboxes for maps that arent effected by the weather at
 the current time. ONLY IF USING A WEATHER EFFECT.
 
 <tint:red,blue,green,grey>
 make sure there is no space's " " when using this notetag !
 This is for maps that have a unique tint, e.g caves
 
=end #==========================================================================#
 
module Dekita_RealTime_Clock
 
  Using_Khas_Awesome_Lights_Script = false#true
 
T_Color ={# << Do Not Delete
 
 
  # Switch Examples.
  #[:switch, switch id, boolean]
  # e.g
  #[:switch, 1, true]
  #[:switch, 8, false]
 
  # Variable Examples.
  #[:variable, variable id, effect type, value]
  # e.g
  #[:variable, 1, :set, 3]  
  #[:variable, 1, :add, 3]
  #[:variable, 1, :sub, 3]
  #[:variable, 1, :div, 3]
  #[:variable, 1, :mul, 3]
 
  # Weather Examples.
  #[weather type, power, sound]
  # e.g
  #[:none]
  #[:rain, 9, "Rain"]
  #[:storm, 1, "Storm"]
  #[:snow, 5, "Wind"]
 
  # Mog Weather Examples.  
  #[:mog_weather, type, power, name, sound]
  # e.g
  #[:mog_weather, 5, 6, "Light_02A", "Rain"]
  #[:mog_weather, 0, 6, "Rain_01A", "Rain"]
 
  # Common Event Example.
  #[:common, common event id]
  # e.g
  #[:common, 15]
 
  # Examples:
  # :_01_30am => [100, 0, 0, 0, true, [:rain, 6], [:switch, 1, true] ],
  # this will make it rain and switch 1 will be true(active) at 1:30 am till 2am
  # and the screen tint will be red .
 
  # :_18_30pm => [ 0, 100, 0, 100, true, [:snow, 6], [:switch, 1, false] ],
  # this will make it snow and switch 1 will be false(inactive) at
  # 6:30 pm till 7pm
 
 
  # Time => [red,green,blue,grey,nighttime?,[effect 1],[effect 2],[effect 3],[effect 4] ]
 
  ## SEASON BEGIN
  :season_1 => { # Season 1 settings
  # Midnight -> Noon
  :_00_00am => [ 0, 0, 0, 200, true, [:none], [nil], [nil], [nil] ],
  :_00_30am => [ 0, 0, 0, 200, true, [:none], [nil], [nil], [nil] ],
  :_01_00am => [ 0, 0, 0, 200, true, [:none], [nil],[nil], [nil] ],
  :_01_30am => [ 0, 0, 0, 200, true, [:none],[nil], [nil], [nil] ],
  :_02_00am => [ 0, 0, 0, 200, true, [:rain, 5, "Rain"],[nil], [nil], [nil] ],
  :_02_30am => [ 0, 0, 0, 200, true, [:rain, 9, "Rain"],[nil], [nil], [nil] ],
  :_03_00am => [ 0, 0, 0, 200, true, [:storm, 7, "Storm"],[nil], [nil], [nil] ],
  :_03_30am => [ 0, 0, 0, 200, true, [:storm, 9, "Storm"],[nil], [nil], [nil] ],
  :_04_00am => [ 0, 0, 0, 200, true, [:rain, 9, "Rain"],[nil], [nil], [nil] ],
  :_04_30am => [ 0, 0, 0, 200, true, [:rain, 5, "Rain"],[nil], [nil], [nil] ],
  :_05_00am => [ 0, 0, 0, 200, true, [:none],[nil], [nil], [nil] ],
  :_05_30am => [ 0, 0, 0, 200, true, [:none],[nil], [nil], [nil] ],
  :_06_00am => [ 0, 0, 0, 200, true, [:snow, 9, "Wind"],[nil], [nil], [nil] ],
  :_06_30am => [ 0, 0, 0, 200, true, [:snow, 9, "Wind"],[nil], [nil], [nil] ],
  :_07_00am => [ 0, 0, 0, 100, false,[:rain, 5, "Rain"],[nil], [nil], [nil] ],
  :_07_30am => [ 0, 0, 0, 100, false,[:storm, 9, "Storm"],[nil], [nil], [nil] ],
  :_08_00am => [ 0, 0, 0, 100, false,[:storm, 5, "Storm"],[nil], [nil], [nil] ],
  :_08_30am => [ 0, 0, 0, 100, false,[:rain, 5, "Rain"],[nil], [nil], [nil] ],
  :_09_00am => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_09_30am => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_10_00am => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_10_30am => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_11_00am => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_11_30am => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  # Noon -> Midnight
  :_12_00pm => [ 0, 0, 0, 100, false,[:rain, 2, "Rain"],[nil], [nil], [nil] ],
  :_12_30pm => [ 0, 0, 0, 100, false,[:rain, 1, "Rain"],[nil], [nil], [nil] ],
  :_13_00pm => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_13_30pm => [ 0, 0, 0, 100, false,[:snow, 9, "Wind"],[nil], [nil], [nil] ],
  :_14_00pm => [ 0, 0, 0, 100, false,[:none],[:switch, 1, true], [:variable, 1, :add, 3], [:common, 1] ],
  :_14_30pm => [ 0, 0, 0, 100, false,[:snow, 9, "Wind"],[nil], [nil], [nil] ],
  :_15_00pm => [ 0, 0, 0, 100, false,[:rain, 9, "Rain"],[nil], [nil], [nil] ],
  :_15_30pm => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_16_00pm => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_16_30pm => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_17_00pm => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_17_30pm => [ 0, 0, 0, 100, false,[:none],[nil], [nil], [nil] ],
  :_18_00pm => [ 0, 0, 0, 100, false,[:rain, 9, "Rain"], [:switch, 1, true], [nil], [nil] ],
  :_18_30pm => [ 0, 0, 0, 100, false,[:snow, 9, "Rain"], [:switch, 1, false], [nil], [nil] ],
  :_19_00pm => [ 0, 0, 0, 100, false,[:none], [nil], [nil], [nil] ],
  :_19_30pm => [ 0, 0, 0, 100, false,[:none], [nil], [nil], [nil] ],  
  :_20_00pm => [ 0, 0, 0, 200, true, [:mog_weather, 5, 6, "Light_02A", "Rain"], [nil], [nil], [nil] ],
  :_20_30pm => [ 0, 0, 0, 200, true, [:mog_weather, 1, 9, "Light_02A", "Rain"], [nil], [nil], [nil] ],
  :_21_00pm => [ 0, 0, 0, 200, true, [:mog_weather, 0, 6, "Rain_01A", "Rain"], [nil], [nil], [nil] ],
  :_21_30pm => [ 0, 0, 0, 200, true, [:mog_weather, 1, 9, "Light_02A", "Rain"], [nil], [nil], [nil] ],
  :_22_00pm => [ 0, 0, 0, 200, true, [:mog_weather, 0, 6, "Light_02A", "Rain"], [:switch, 1, true], [nil], [nil] ],
  :_22_30pm => [ 0, 0, 0, 200, true, [:mog_weather, 0, 6, "Light_02A", "Rain"], [:switch, 1, true], [nil], [nil] ],
  :_23_00pm => [ 0, 0, 0, 200, true, [:rain, 9, "Rain"],[nil], [nil], [nil] ],
  :_23_30pm => [ 0, 0, 0, 200, true, [:none],[nil], [nil], [nil] ],
 
  }, # Do Not Delete
  ## SEASON END
 
  # If you wish to add more than 1 season simply follow these instructions.
  # 1 - Copy from SEASON BEGIN (around line 109) upto and including..
  #   - SEASON END(around line 163)
  # 2 - Paste a new "season" below SEASON END  
  # 3 - directly under SEASON BEGIN (of the season you just pasted)
  #   - find the line that says  " :season_1 => { # Season 1 settings "
  # 4 - change " :season_1 " to whatever you want to call it
  # 5 - look below and you will find the "Months" section, simply rename
  #   - the season in here for the months you wish to use for your new season
  # e.g  
  #  1  => [:season_1],
  #  2  => [:season_2],
  #  3  => [:season_3],
 
  } # << ALL SEASONS END
 
  Months ={
  1  => [:season_1], # January
  2  => [:season_1], # Febuary
  3  => [:season_1], # March
  4  => [:season_1], # April
  5  => [:season_1], # May
  6  => [:season_1], # June
  7  => [:season_1], # July
  8  => [:season_1], # August
  9  => [:season_1], # September
  10 => [:season_1], # October
  11 => [:season_1], # November
  12 => [:season_1], # December
  }
 
  #####################################
  # * YOUR OWN CUSTOM EFFECTS BELOW * #
  #####################################
 
  def self.custom_time_effects(condition) # < !!
    case condition[0] # DO NOT DELETE THESE < !!
    # the condition that gets passed is the condition slot
    # for the current time period eg. " [:snow, 6, "Wind"] "
  #--------------------------------------------------------------------------
  # * change_weather(type, power, duration)
  #     type = :none, :rain, :storm, :snow
  #     power = 0 - 9 # 0 = weak | 9 = strong
  #     duration = 0  # for instant change upon transfer
  #--------------------------------------------------------------------------
    when :none
      $game_map.screen.change_weather(:none, 0, 0)
      if $mog_rgss3_weather_ex == true
        $game_temp.weather_fade = false
        $game_system.weather.clear
        $game_system.weather = [-1,0,""]
        $game_system.weather_restore = [-1,0,""]
        $game_system.weather_temp = [-1,0,""]
      end
      Audio.bgs_fade(30)
    when :rain, :storm, :snow
      if $game_map.can_weather
        $game_map.screen.change_weather(condition[0], condition[1], 0)
        Audio.bgs_play("Audio/BGS/" + condition[2], 10 * condition[1], 100)
      else
        $game_map.screen.change_weather(:none, 0, 0)
        Audio.bgs_play("Audio/BGS/" + condition[2], 7 * condition[1], 100)
      end
    when :mog_weather # [:mog_weather, type, power, name, sound]
      return unless $mog_rgss3_weather_ex == true
      if $game_map.can_weather
        $game_temp.weather_fade = false
        if $game_system.weather != [condition[1],condition[2],condition[3]]
          $game_system.weather.clear
        end
        $game_system.weather = [condition[1],condition[2],condition[3]]
        Audio.bgs_play("Audio/BGS/" + condition[4], 10 * condition[2], 100)
      else
        $game_temp.weather_fade = false
        $game_system.weather.clear
        $game_system.weather = [-1,0,""]
        $game_system.weather_restore = [-1,0,""]
        $game_system.weather_temp = [-1,0,""]
        Audio.bgs_play("Audio/BGS/" + condition[4], 7 * condition[2], 100)
      end
  #--------------------------------------------------------------------------
  # * YOUR OWN CUSTOM EFFECTS
  # Here you can create you own custom effects, (with some scripting knowladge)
  # you can then call the effect by putting [:custom] into the condition slot
  # for each time period. make sure " :custom " matches the effect you want.
  # Above is how i set up the basic weather effects for an example.
  #--------------------------------------------------------------------------
    when :custom
      #---
      # insert code here
      #---
    when :custom_2
      #---
      # insert code here
      #---
 
#===============================================================================#
############################# CUSTOMISATION END #################################
#===============================================================================#
#☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★#
#                                                                               #
#                       http://dekitarpg.wordpress.com/                         #
#                                                                               #
#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆#
#===============================================================================#
# ARE YOU MODIFYING BEYOND THIS POINT? \.\.                                     #
# YES?\.\.                                                                      #
# OMG, REALLY? \|                                                               #
# WELL SLAP MY FACE AND CALL ME A DITTO.\..\..                                  #
# I REALLY DIDN'T THINK YOU HAD IT IN YOU.\..\..                                #
#===============================================================================#  
 
    end# << DO NOT DELETE THESE
  end  # <<
 
 
end
 
$imported = {} if $imported.nil?
$imported[:Dekita_Pokémon_RealTime_Clock] = true
 
#===============================================================================#
class RPG::Map
#===============================================================================#
 
  attr_reader :can_tint
  attr_reader :can_weather_effects
  attr_reader :has_unique_tint
 
  def get_tint_info
    @can_tint = true
    @can_weather_effects = true
    @has_unique_tint = [false, nil, nil, nil, nil]
    self.note.split(/[\r\n]+/).each { |line|
    case line
    when /<no tint>/i
      @can_tint = false
      #---
    when /<no weather>/i
      @can_weather_effects = false
      #---
    when /<tint:(.*),(.*),(.*),(.*)>/i
      @has_unique_tint = [true, $1.to_i, $2.to_i, $3.to_i, $4.to_i]
      #---
    end
    } # self.note.split
  end  
 
end
 
#==============================================================================
class Game_Temp
#==============================================================================
 
  attr_accessor :last_used__restricted_tint_effect
 
  alias dekitarealtimesystemgt initialize
  def initialize
    dekitarealtimesystemgt
    @last_used__restricted_tint_effect = [[nil],[nil],[nil],[nil]]
  end
 
end
 
#==============================================================================
class Game_System
#==============================================================================
if !$imported[:Dekita__Pokémon_CORE] ; attr_accessor :night_time ; end
 
  attr_accessor :refresh_the_map_for_tint
  attr_accessor :screen_tint
 
  alias :init_de_map_tintzz :initialize
  def initialize
    init_de_map_tintzz
    @screen_tint = get_time_light
    @refresh_the_map_for_tint = false
    @night_time = false if !$imported[:Dekita__Pokémon_CORE]
  end
 
  def get_time_sym
    case Time.now.hour
    when 0  ; sym = Time.now.min < 30 ? :_00_00am : :_00_30am
    when 1  ; sym = Time.now.min < 30 ? :_01_00am : :_01_30am
    when 2  ; sym = Time.now.min < 30 ? :_02_00am : :_02_30am
    when 3  ; sym = Time.now.min < 30 ? :_03_00am : :_03_30am
    when 4  ; sym = Time.now.min < 30 ? :_04_00am : :_04_30am
    when 5  ; sym = Time.now.min < 30 ? :_05_00am : :_05_30am
    when 6  ; sym = Time.now.min < 30 ? :_06_00am : :_06_30am
    when 7  ; sym = Time.now.min < 30 ? :_07_00am : :_07_30am
    when 8  ; sym = Time.now.min < 30 ? :_08_00am : :_08_30am
    when 9  ; sym = Time.now.min < 30 ? :_09_00am : :_09_30am
    when 10 ; sym = Time.now.min < 30 ? :_10_00am : :_10_30am
    when 11 ; sym = Time.now.min < 30 ? :_11_00am : :_11_30am
    when 12 ; sym = Time.now.min < 30 ? :_12_00pm : :_12_30pm
    when 13 ; sym = Time.now.min < 30 ? :_13_00pm : :_13_30pm
    when 14 ; sym = Time.now.min < 30 ? :_14_00pm : :_14_30pm
    when 15 ; sym = Time.now.min < 30 ? :_15_00pm : :_15_30pm
    when 16 ; sym = Time.now.min < 30 ? :_16_00pm : :_16_30pm
    when 17 ; sym = Time.now.min < 30 ? :_17_00pm : :_17_30pm
    when 18 ; sym = Time.now.min < 30 ? :_18_00pm : :_18_30pm
    when 19 ; sym = Time.now.min < 30 ? :_19_00pm : :_19_30pm
    when 20 ; sym = Time.now.min < 30 ? :_20_00pm : :_20_30pm
    when 21 ; sym = Time.now.min < 30 ? :_21_00pm : :_21_30pm
    when 22 ; sym = Time.now.min < 30 ? :_22_00pm : :_22_30pm
    when 23 ; sym = Time.now.min < 30 ? :_23_00pm : :_23_30pm
    end ; return sym
  end
 
  def get_time_light
    sym = get_time_sym
    season = Dekita_RealTime_Clock::Months[Time.now.mon][0]
    tset = Dekita_RealTime_Clock::T_Color[season][sym]
    if SceneManager.scene != Scene_Map || Scene_Battle
      return [tset[0], tset[1], tset[2], tset[3]]
    elsif $game_map.has_unique_tint[0]
      gmt = $game_map.has_unique_tint
      return [gmt[1], gmt[2], gmt[3], gmt[4]]
    else
      return [tset[0], tset[1], tset[2], tset[3]]
    end
  end
 
  def update_time_light
    sym = get_time_sym
    season = Dekita_RealTime_Clock::Months[Time.now.mon][0]
    tset = Dekita_RealTime_Clock::T_Color[season][sym]
    if tset[5] != nil ; update_unique_effects(tset[5], sym, 0) ; end
    if tset[6] != nil ; update_unique_effects(tset[6], sym, 1) ; end
    if tset[7] != nil ; update_unique_effects(tset[7], sym, 2) ; end
    if tset[8] != nil ; update_unique_effects(tset[8], sym, 3) ; end
    if SceneManager.scene != Scene_Map || Scene_Battle
      return [tset[0], tset[1], tset[2], tset[3]]
    elsif $game_map.has_unique_tint[0]
      gmt = $game_map.has_unique_tint
      return [gmt[1], gmt[2], gmt[3], gmt[4]]
    else
      return [tset[0], tset[1], tset[2], tset[3]]
    end
  end
 
  def update_unique_effects(tset, sym, gt_id)
    last_effect = $game_temp.last_used__restricted_tint_effect[gt_id]
    case tset[0]#[0]
    when :switch
      return if last_effect == [:switch, sym]
      $game_temp.last_used__restricted_tint_effect[gt_id] = [:switch, sym]
      $game_switches[ tset[1] ] = tset[2]
    when :variable
      case tset[2]
      when :set
        return if last_effect == [:set, sym]
        $game_temp.last_used__restricted_tint_effect[gt_id] = [:set, sym]
        $game_variables[tset[1]] = tset[3]
      when :add
        return if last_effect == [:add, sym]
        $game_temp.last_used__restricted_tint_effect[gt_id] = [:add, sym]
        $game_variables[tset[1]] = ($game_variables[tset[1]]+tset[3]).to_i
      when :sub
        return if last_effect == [:sub, sym]
        $game_temp.last_used__restricted_tint_effect[gt_id] = [:sub, sym]
        $game_variables[tset[1]] = ($game_variables[tset[1]]-tset[3]).to_i
      when :div
        return if last_effect == [:div, sym]
        $game_temp.last_used__restricted_tint_effect[gt_id] = [:div, sym]
        $game_variables[tset[1]] = ($game_variables[tset[1]]/tset[3]).to_i
      when :mul
        return if last_effect == [:mul, sym]
        $game_temp.last_used__restricted_tint_effect[gt_id] = [:mul, sym]
        $game_variables[tset[1]] = ($game_variables[tset[1]]*tset[3]).to_i
      end
    when :common
      return if last_effect == [:common, sym]
      $game_temp.last_used__restricted_tint_effect[gt_id] = [:common, sym]
      $game_temp.reserve_common_event(tset[1])
    else
      Dekita_RealTime_Clock.custom_time_effects(tset)
    end
  end
 
end
 
#===============================================================================#
class Game_Map
#===============================================================================#
 
  attr_reader :map_tintable
  attr_reader :can_weather
  attr_reader :has_unique_tint
 
  alias mapsetupforpkmntimesys setup
  def setup(map_id)
    mapsetupforpkmntimesys(map_id)
    @map.get_tint_info
    @map_tintable = @map.can_tint
    @can_weather = @map.can_weather_effects
    @has_unique_tint = @map.has_unique_tint
  end
 
end
 
#===============================================================================#
module Time_Tint
#===============================================================================#
 
  def self.updt
    $game_system.screen_tint = $game_system.update_time_light
    if $game_map.map_tintable == false
      rc = 0 ; gc = 0 ; bc = 0 ; al = 0
    elsif $game_map.has_unique_tint[0]
      rc = $game_map.has_unique_tint[1]
      gc = $game_map.has_unique_tint[2]
      bc = $game_map.has_unique_tint[3]
      al = $game_map.has_unique_tint[4]
    else
      rc = $game_system.screen_tint[0]
      gc = $game_system.screen_tint[1]
      bc = $game_system.screen_tint[2]
      al = $game_system.screen_tint[3]
    end
    if Dekita_RealTime_Clock::Using_Khas_Awesome_Lights_Script
#      tone = Tone.new(rc,gc,bc,al/4)
      $game_map.effect_surface.change_color(0,rc,gc,bc)
      $game_map.effect_surface.set_alpha(al)
#      $game_map.screen.start_tone_change(tone, 0)      
    else
      tone = Tone.new(rc,gc,bc,al)
      $game_map.screen.start_tone_change(tone, 0)      
    end
  end
 
end
 
#==============================================================================
class Scene_Map < Scene_Base
#==============================================================================
 
  alias realtimestartthatshit start
  def start
    realtimestartthatshit
    start_de_sprttone
  end
 
  def start_de_sprttone
    Time_Tint.updt
    @time_tint_min = Time.now.min#sec
  end
 
  alias realtimeupdatetime update
  def update
    realtimeupdatetime
    update_DPBz_effects if @time_tint_min != Time.now.min#sec
  end
 
  def update_DPBz_effects
    @time_tint_min = Time.now.min
    Time_Tint.updt
  end
 
end
 
#==============================================================================
class Scene_Load < Scene_File
#==============================================================================
 
  alias ols_on_load_success on_load_success
  def on_load_success
    ols_on_load_success
    add_load_time_fix
  end
 
  def add_load_time_fix
    $game_system.screen_tint = $game_system.update_time_light
    $game_system.refresh_the_map_for_tint = true
    if !Dekita_RealTime_Clock::Using_Khas_Awesome_Lights_Script
    end
   
  end
 
end
 
#==============================================================================
class Game_Interpreter
#==============================================================================
 
  alias com201pkmnrt_transfer_fade_ALIAS command_201
  def command_201
    return if $game_party.in_battle
    $game_map.screen.start_fadeout(30)
    if $mog_rgss3_weather_ex == true ; $game_system.weather.clear ; end
    com201pkmnrt_transfer_fade_ALIAS
    $game_system.screen_tint = $game_system.update_time_light
    $game_system.refresh_the_map_for_tint = true
    $game_map.screen.start_fadein(30)
  end
 
end
 
#===============================================================================#
#                               - SCRIPT END -                                  #
#===============================================================================#
#                      http://dekitarpg.wordpress.com/                          #
#===============================================================================#