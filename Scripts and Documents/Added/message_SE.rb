#Basic Message SE v1.1
#----------#
#Features: Let's you have a sound effect play every so-so letters while a
#           message is being displayed. Fancy!
#
#Usage:    Plug and play, script calls to change details in game:
#
#           message_freq(value)      - changes the frequency of the se
#           message_se("string")     - name of the se to play
#           message_volume(value)    - volume of the se to play
#           message_pitch([min,max]) - pitch variance between min and max
#           message_set(se,volume,pitch) - sets them all at once
#           message_set(se,volume,pitch,freq) - same as above but with freq
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!
 
class Window_Message < Window_Base
 
  DEFAULT_SE_FREQ = 5
  DEFAULT_AUDIO_SOUND = "Cancel2"
  DEFAULT_AUDIO_VOLUME = 75
  DEFAULT_AUDIO_PITCH = [75,125]
 
  DISABLE_SOUND_SWITCH = 29
 
  attr_accessor  :se
  attr_accessor  :freq
  attr_accessor  :volume
  attr_accessor  :pitch
 
  alias mse_clear_instance_variables clear_instance_variables
  def clear_instance_variables
    mse_clear_instance_variables
    @key_timer = 0
    reset_se_variables
  end
  def reset_se_variables
    @se = DEFAULT_AUDIO_SOUND
    @volume = DEFAULT_AUDIO_VOLUME
    @pitch = DEFAULT_AUDIO_PITCH
    @freq = DEFAULT_SE_FREQ
  end
  def process_normal_character(c, pos)
    super
    if !$game_options.nil?
      return wait_for_one_character unless $game_options.message_se
    end
    return wait_for_one_character if $game_switches[DISABLE_SOUND_SWITCH]
    if @key_timer % @freq == 0
      Audio.se_play("Audio/SE/" + @se, @volume, rand(@pitch[1]-@pitch[0]) + @pitch[0])
    end
    @key_timer += 1
    wait_for_one_character
  end
end
 
class Scene_Map
  attr_accessor  :message_window
end
 
class Game_Interpreter
  def message_set(string, value, array, freq = -1)
    message_se(string)
    message_volume(value)
    message_pitch(array)
    message_freq(freq) if freq >= 0
  end
  def message_freq(value)
    SceneManager.scene.message_window.freq = value
  end
  def message_se(string)
    SceneManager.scene.message_window.se = string
  end
  def message_pitch(array)
    SceneManager.scene.message_window.pitch = array
  end
  def message_volume(value)
    SceneManager.scene.message_window.volume = value
  end
  def message_reset
    SceneManager.scene.message_window.reset_se_variables
  end
end