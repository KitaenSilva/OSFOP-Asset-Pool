=begin
#===============================================================================
 Title: Windowskin Changer
 Author: Hime
 Date: Dec 10, 2014
--------------------------------------------------------------------------------
 ** Change log
 Dec 10, 2014
   - fixed bug where windows created by the message window are not refreshed
 Nov 10, 2014
   - properly updates current window
 Nov 9, 2014 
   - Initial Release
--------------------------------------------------------------------------------  
 ** Terms of Use
 * Free to use in non-commercial projects
 * Contact me for commercial use
 * No real support. The script is provided as-is
 * Will do bug fixes, but no compatibility patches
 * Features may be requested but no guarantees, especially if it is non-trivial
 * Credits to Hime Works in your project
 * Preserve this header
--------------------------------------------------------------------------------
 ** Description
 
 By default, RPG Maker uses the file called "Window" stored in the
 Graphics/System folder, and only supports one windowskin throughout the game.

 This script allows you to change window skins dynamically during the game
 using script calls. For example, you can change window skins depending on the
 current actor that's speaking, or to reflect the player's current alignment.

--------------------------------------------------------------------------------
 ** Installation
 
 In the script editor, place this script below Materials and above Main
 
--------------------------------------------------------------------------------
 ** Usage
 
 Place all windowskins in the Graphics/System folder.
 
 To change windowskins, make a script call

   set_windowskin(NAME)
   
 Where the NAME is the name of the windowskin that you want to change to.
 
--------------------------------------------------------------------------------
 ** Example
 
 Suppose you have a windowskin called 
 
   grassy
   
 To use this window skin, make the script call
 
   set_windowskin("grassy")
   
 Note the quotes.
 
#===============================================================================
=end
$imported = {} if $imported.nil?
$imported[:TH_WindowskinChanger] = true
#===============================================================================
# ** Configuration
#===============================================================================
module TH
  module Windowskin_Changer
    
    # Set this to true if you have scenes that don't inherit from Scene_Base
    Compatibility_Mode = false
  end
end
#===============================================================================
# ** Rest of Script
#===============================================================================
class Game_System
  
  attr_reader :windowskin
  
  alias :th_windowskin_changerinitialize :initialize
  def initialize
    th_windowskin_changerinitialize
    @windowskin = "Window"
  end
  
  def windowskin=(name)
    @windowskin = name
    SceneManager.scene.set_windowskin
  end
end

class Game_Interpreter
  
  def set_windowskin(name)
    $game_system.windowskin = name
  end
end

class Scene_Base
  def set_windowskin
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.refresh_windowskin if ivar.is_a?(Window)
    end
  end
end

class Window_Base
  
  attr_reader :windowskin_refreshed
  
  alias :th_windowskin_changer_initialize :initialize
  def initialize(*args)
    th_windowskin_changer_initialize(*args)
    
    self.windowskin = Cache.system($game_system.windowskin)
  end
  
  #-----------------------------------------------------------------------------
  # Refresh the windowskin explicitly. Also need to check all instance variables
  # in case it holds other windows
  #-----------------------------------------------------------------------------
  def refresh_windowskin
    @windowskin_refreshed = true
    self.windowskin = Cache.system($game_system.windowskin)
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      ivar.refresh_windowskin if ivar.is_a?(Window) && !ivar.windowskin_refreshed
    end
    refresh if respond_to?(:refresh)
    @windowskin_refreshed = false
  end
end

#===============================================================================
# If for some reason you are using a script with a scene that does not inherit
# from Scene_Base, enable compatibility mode in the configuration
#===============================================================================
if TH::Windowskin_Changer::Compatibility_Mode
  class Window
    
    alias :th_windowskin_changer_update :update
    def update
      th_windowskin_changer_update
      update_windowskin    
    end
    
    def update_windowskin
      if $game_system != self.windowskin
        self.windowskin = Cache.system($game_system.windowskin)
      end
    end
  end
end