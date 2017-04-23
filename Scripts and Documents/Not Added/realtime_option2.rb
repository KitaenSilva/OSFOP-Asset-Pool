#===============================================================================
# * Gumps System Time Reactions Script
# * Version: 1.0.0
# * Author: Matt 'Gump' Sully
#-------------------------------------------------------------------------------
# * Description:
# > This Script provides a simple way of having reactions in your game based
# on the current system time of the computer your game is being played on.
# > This can allow you to have specific things happen at specific times, or
# possibly insert nice time related secrets into your game!
#-------------------------------------------------------------------------------
# * LEGAL:
# > You may freely use this script in any free or commercial game.
# > If you use this script, providing credit is not required.
#-------------------------------------------------------------------------------
# * Instructions:
# > You must define Realtimes with Actions in The "Definitions" part of the
# Settings. 
# > First you define the required time, then you define the action.
# > You can either turn on/off a single switch, or change the value of a single
# variable, or both.
# > Available Time properties are called using :symbols. The following Table
# Shows you what symbols are available and their valid range.
# :second = 0 - 59
# :minute = 0 - 59
# :hour   = 0 - 23
# :day    = 1 - 31
# :month  = 1 - 12 
# :year   = 0 - 99
# > Avaialble Action properties: These also use :symbols.
# :game_switch = [switch_id, true/false]
# :game_variable = [variable_id, value]
#
# Sample Configs:
#--------------------------------------------
# > This configuration will turn switch 75 ON when it is Hour 1, Minute 27.
#
#    Timevents['sample_time'] = {}
#    Timevents['sample_time'][:minute] = 27
#    Timevents['sample_time'][:hour] = 1
#    Actions['sample_time'] = {}
#    Actions['sample_time'][:game_switch] = [75, true]
#
# > This configuration will turn switch 71 ON and SET variable 55 to a value of
# 115 when it is Month 5, Day 15, Hour 7, Minute 15, Second 5.
#
#    Timevents['easter_egg_417'] = {}
#    Timevents['easter_egg_417'][:second] = 5
#    Timevents['easter_egg_417'][:minute] = 15
#    Timevents['easter_egg_417'][:hour] = 7
#    Timevents['easter_egg_417'][:day] = 15
#    Timevents['easter_egg_417'][:month] = 5
#    Actions['easter_egg_417'] = {}
#    Actions['easter_egg_417'][:game_switch] = [71, true]
#    Actions['easter_egg_417'][:game_variable] = [55, 115]
#
# > Oh, and you see How each of these events have different names? One is
# 'sample_time' and one is 'easter_egg_417'. These names are simply put here for
# your convenience as a developer. Choose a name for your time event that will
# relate to your game/situation. Your name doesn't have to be a 'string'. It can
# be a :symbol or an integer if desired.
#
#===============================================================================
#
#-------------------------------------------------------------------------------
# * Initializing Warp Core... Don't touch the next few lines please.
module GUMPSRTR # Don't touch this line sir or madam.
  Timevents = {} # Don't touch this line sir or madam.
  Actions = {} # Don't touch this line sir or madam.
  @system_time = {} # Don't touch this line sir or madam.
  @rtr_event_que = [] # Don't touch this line sir or madam.
  #
  # Initialization Complete. I hope you didn't touch those lines...
  #
  #--------------------------------------------------------------------------
  # * SETTINGS
  #---------------------------------------------------------------------------
  # The Check Delay is the delay time in FRAMES before each system time Check.
  # Normally, your game will process 60 frames per second.
  # Default Value: 20
  #---------------------------------------------------------------------------
  CHECK_DELAY_FRAMES = 20
  #
  #
  #
  #-------------------------------------------------------------------
  # * DEFINITIONS SETTINGS:
  # > This is where you define the times and the actions to take!
  # > Definitions are important. With no definitions, there is no time.
  # > There is 1 sample definition here by default, and you should
  # probably remove it and replace it with your own set.
  #-------------------------------------------------------------------
  # *** INSERT YOUR DEFINITIONS UNDER THIS LINE! ***
  #
  
  
  Timevents['sample_time'] = {}
  Timevents['sample_time'][:minute] = 27
  Timevents['sample_time'][:hour] = 1
  Actions['sample_time'] = {}
  Actions['sample_time'][:game_switch] = [75, true]

  
  
  #
  # *** INSERT YOUR DEFINITIONS ABOVE THIS LINE! ***
  #--------------------------------------------------------------------------
  # * END OF SETTINGS! DON'T EDIT BELOW THIS LINE UNLESS YER SCRIPTIN'
  #--------------------------------------------------------------------------
  def self.get_system_time
    @system_time[:second] = Time.now.strftime('%S').to_i
    @system_time[:minute] = Time.now.strftime('%M').to_i
    @system_time[:hour] = Time.now.strftime('%H').to_i
    @system_time[:day] = Time.now.strftime('%d').to_i
    @system_time[:month] = Time.now.strftime('%m').to_i
    @system_time[:year] = Time.now.strftime('%y').to_i
  end
  
  def self.check_for_timevent
    break_op = false
    evkeys = Timevents.keys
    ackeys = Actions.keys
    index = 0
    self.get_system_time
    for i in 0...evkeys.size
      key = evkeys[index]
      data = Timevents[key]
      subindex = 0; dtkeys = data.keys
      for i in 0...dtkeys.size
        kread = dtkeys[subindex]
        crc = data[kread]
        if @system_time[kread] == crc
          @rtr_event_que << key if subindex >= dtkeys.size - 1
        else
          break_op = true
        end
        subindex += 1
        break if break_op
      end
      index += 1
      break if break_op
    end
    self.initialize_queued_events if @rtr_event_que.size > 0
  end
  
  def self.initialize_queued_events
    return if @rtr_event_que.size < 0
    index = 0
    for i in 0...@rtr_event_que.size
      key = @rtr_event_que[index]
      p "Error: Undefined actions for #{key} in Gump Realtime Reaction Script" if $TEST && Actions[key].nil?
      data = Actions[key]
      subindex = 0; symbols = data.keys
      for i in 0...symbols.size
        tmp1 = symbols[subindex]
        if symbols[subindex] == :game_switch
          res = Actions[key][tmp1]
          switch = res[0]
          value = res[1]
          if value != true && value != false
            p "Error in Gump Realtime Reaction Script: Invalid Switch Parameter. Must be true or false" if $TEST
          end
          next if value != true || false
          $game_switches[switch] = value
        elsif symbols[subindex] == :game_variable
          res = Actions[key][tmp1]
          var_id = res[0]
          value = res[1]
          $game_variables[var_id] = value
        end
        subindex += 1
      end
      index += 1
      
    end
    @rtr_event_que.clear
  end
  
  
end


class Scene_Map < Scene_Base
  alias :gump_rtr_update_78932trh0  :update
  def update(*args)
    gump_rtr_update_78932trh0
    update_systemtime_reactions_gump
  end
  def update_systemtime_reactions_gump
    @gumprtr_delay ||= 0
    @gumprtr_delay += 1
    if @gumprtr_delay >= GUMPSRTR::CHECK_DELAY_FRAMES
      @gumprtr_delay = 0
      GUMPSRTR.check_for_timevent
    end
  end
end