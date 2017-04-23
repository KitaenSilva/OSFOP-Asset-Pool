#==============================================================================
#   XaiL System - Quit
#   Author: Nicke
#   Created: 16/01/2012
#   Edited: 17/01/2012
#   Version: 1.0
#==============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ▼ Materials but above ▼ Main. Remember to save.
#
# Note: This script must be placed below XS - Core and XS - Title.
#
# *** Only for RPG Maker VX Ace. ***
#==============================================================================
($imported ||= {})["XAIL-XS-QUIT"] = true

module XAIL
  module QUIT
  #--------------------------------------------------------------------------#
  # * Settings
  #--------------------------------------------------------------------------#
  # QUIT list, the icon_index (set to nil) and custom_scene is optional.
  # QUIT_LIST:
  # ID = ['Title', :symbol, :command, icon_index, custom_scene (not needed) ]
  QUIT_LIST = []
  QUIT_LIST[0] = ['To Title', :to_title, :command_to_title, 121]
  QUIT_LIST[1] = ['New Game', :new_game, :command_new_game, 125]
  QUIT_LIST[2] = ['Save',	 :save,	 :command_custom,   229,  Scene_Save]
  QUIT_LIST[3] = ['Load',	 :continue, :command_continue, 232]
  QUIT_LIST[4] = ['Quit',	 :shutdown, :command_shutdown, 1]

  # If center window is true you cannot modify the x value.
  # QUIT_WINDOW [ Width, x, y, z, opacity, center window]
  QUIT_WINDOW = [160, 0, 50, 200, 255, true]

  # QUIT_ALIGNMENT = 0 (left), 1 (center), 2 (right)
  QUIT_ALIGNMENT = 0 # Default: 0.

  # The windowskin to use for the windows.
  # nil to disable.
  # SKIN = string
  SKIN = nil

  # Disable all of the icons if you don't need them.
  # ICON_ENABLE = true/false
  ICON_ENABLE = true

  # Transition, nil to use default.
  # TRANSITION [ SPEED, TRANSITION, OPACITY ]
  # TRANSITION = [40, "Graphics/Transitions/1", 50]
  TRANSITION = nil

  # Animate options.
  # Set ANIM_WINDOW_TIMER to nil to disable.
  ANIM_WINDOW_TIMER = 5 # Fade in time for window/icons.
  ANIM_SCENE_FADE = 1000 # Fade out time for scene. Default: 1000.
  ANIM_AUDIO_FADE = 1000 # Fade out time for audio. Default: 1000.

  end
end
# *** Don't edit below unless you know what you are doing. ***
#==============================================================================
# ** Window_QuitCommand
#==============================================================================
class Window_QuitCommand < Window_Command

  def initialize
	super(0, 0)
	self.openness = 0
	open
  end

  def window_width
	# // Method to return the width of QUIT_WINDOW.
	return XAIL::QUIT::QUIT_WINDOW[0]
  end

  def alignment
	# // Method to return the alignment.
	return XAIL::QUIT::QUIT_ALIGNMENT
  end

  def continue_enabled
	# // Method to check if a save file exists.
	DataManager.save_file_exists?
  end

  def save_enabled
	# // Method to check if save is enabled.
	!$game_system.save_disabled
  end

  def make_command_list
	# // Method to add the commands.
	for i in XAIL::QUIT::QUIT_LIST
	  case i[1]
	  when :continue # Load
		add_command(i[0], i[1], continue_enabled, i[4])
	  when :save
		add_command(i[0], i[1], save_enabled, i[4])
	  else
		add_command(i[0], i[1], true, i[4])
	  end
	end
  end

end
#==============================================================================#
# ** Scene_End
#------------------------------------------------------------------------------
#  New Scene :: Scene_End
#==============================================================================#
class Scene_End < Scene_MenuBase

  alias xail_quit_start start
  def start(*args, &block)
	# // Method to start the scene.
	super
	xail_quit_start(*args, &block)
	create_quit_icon_window
	create_quit_command_window
  end

  def terminate
	# // Method to terminate.
	super
  end

  def create_quit_command_window
	# // Method to create the commands.
	@command_window = Window_QuitCommand.new
	@command_window.windowskin = Cache.system(XAIL::QUIT::SKIN) unless XAIL::QUIT::SKIN.nil?
	if XAIL::QUIT::QUIT_WINDOW[5]
	  @command_window.x = (Graphics.width - @command_window.width) / 2
	else
	  @command_window.x = XAIL::QUIT::QUIT_WINDOW[1]
	end
	@command_window.y = XAIL::QUIT::QUIT_WINDOW[2]
	@command_window.z = XAIL::QUIT::QUIT_WINDOW[3]
	@command_window.opacity = XAIL::QUIT::QUIT_WINDOW[4]
	for i in XAIL::QUIT::QUIT_LIST
	  @command_window.set_handler(i[1], method(i[2]))
	end
	@command_window.set_handler(:cancel, method(:return_scene))
	pre_animate_in(@command_window) unless XAIL::QUIT::ANIM_WINDOW_TIMER.nil?
  end

  def create_quit_icon_window
	# // Method to create the menu icon window.
	@command_icon = Window_Icon.new(0, 0, @command_window.width, XAIL::QUIT::QUIT_LIST.size)
	@command_icon.alignment = XAIL::QUIT::QUIT_ALIGNMENT
	@command_icon.enabled = XAIL::QUIT::ICON_ENABLE
	@command_icon.draw_cmd_icons(XAIL::QUIT::QUIT_LIST, 3)
	if XAIL::QUIT::QUIT_WINDOW[5]
	  @command_icon.x = (Graphics.width - @command_window.width) / 2
	else
	  @command_icon.x = XAIL::QUIT::QUIT_WINDOW[1]
	end
	@command_icon.y = XAIL::QUIT::QUIT_WINDOW[2]
	@command_icon.z = 201
	unless XAIL::QUIT::ANIM_WINDOW_TIMER.nil?
	  @command_icon.opacity = 255
	  pre_animate_in(@command_icon)
	else
	  @command_icon.opacity = 0
	end
  end

  def pre_animate_in(command)
	# // Method for pre_animate the window.
	command.opacity -= 255
	command.contents_opacity -= 255
  end

  def fade_animate(command, fade)
	# // Method for fading in/out.
	timer = XAIL::QUIT::ANIM_WINDOW_TIMER
	while timer > 0
	  Graphics.update
	  case fade
	  when :fade_in
	  command.opacity += 255 / XAIL::QUIT::ANIM_WINDOW_TIMER unless command == @command_icon
	  command.contents_opacity += 255 / XAIL::QUIT::ANIM_WINDOW_TIMER
	  when :fade_out
	  command.opacity -= 255 / XAIL::QUIT::ANIM_WINDOW_TIMER unless command == @command_icon
	  command.contents_opacity -= 255 / XAIL::QUIT::ANIM_WINDOW_TIMER  
	  end
	  command.update
	  timer -= 1
	end
  end

  def post_start
	# // Method for post_start.
	super
	unless XAIL::QUIT::ANIM_WINDOW_TIMER.nil?
	  fade_animate(@command_window, :fade_in)
	  fade_animate(@command_icon, :fade_in)
	end
  end

  def close_command_window
	# // Method for close_command_window.
	unless XAIL::QUIT::ANIM_WINDOW_TIMER.nil?
	  fade_animate(@command_icon, :fade_out)
	  fade_animate(@command_window, :fade_out)
	end
  end

  def fadeout_scene
	time = XAIL::QUIT::ANIM_AUDIO_FADE
	# // Method to fade out the scene.
	RPG::BGM.fade(time)
	RPG::BGS.fade(time)
	RPG::ME.fade(time)
	Graphics.fadeout(XAIL::QUIT::ANIM_SCENE_FADE * Graphics.frame_rate / 1000)
	RPG::BGM.stop
	RPG::BGS.stop
	RPG::ME.stop
  end

  def command_new_game
	 # // Method to call new game.
	if $imported["XAIL-XS-TITLE"]
	  return command_new_game_xail
	end
	DataManager.setup_new_game
	close_command_window
	fadeout_all
	$game_map.autoplay
	SceneManager.goto(Scene_Map)
  end

  def command_new_game_xail
	# // Method to call new game (if XS-Title is imported).
	DataManager.setup_new_game
	close_command_window
	fadeout_scene
	$game_map.autoplay
	if !XAIL::TITLE::SWITCHES.nil?
	  for i in XAIL::TITLE::SWITCHES
		$game_switches[i] = true
	  end
	end
	if !XAIL::TITLE::COMMON_EVENT.nil?
	  $game_temp.reserve_common_event(XAIL::TITLE::COMMON_EVENT)
	end
	SceneManager.goto(Scene_Map)
  end

  def command_continue
	# // Method to call load.
	close_command_window
	SceneManager.call(Scene_Load)
  end

  def command_custom
	# // Method to call a custom command.
	SceneManager.goto(@command_window.current_ext)
  end

  def perform_transition
	# // Method to perform a transition.
	if XAIL::QUIT::TRANSITION.nil?
	  Graphics.transition(15)
	else
	  Graphics.transition(XAIL::QUIT::TRANSITION[0],XAIL::QUIT::TRANSITION[1],XAIL::QUIT::TRANSITION[2])
	end
  end

end # END OF FILE

#=*==========================================================================*=#
# ** END OF FILE
#=*==========================================================================*=#