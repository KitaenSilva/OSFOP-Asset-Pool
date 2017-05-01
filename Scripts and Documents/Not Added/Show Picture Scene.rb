#==============================================================================#
#                           RK5's Show Picture Scene                           #
#==============================================================================#
#                           Author:  Rikifive                                  #
#                           For:     RPGMAKER VX ACE                           #
#                           Version: 1.0                                       #
#------------------------------------------------------------------------------#
# -=[ VERSION HISTORY ]=-                                                      #
#------------------------------------------------------------------------------#
#  2015-11-25 -> Version 1.0                                                   #
#             - Release                                                        #
#------------------------------------------------------------------------------#
# -=[ DESCRIPTION ]=-                                                          #
#------------------------------------------------------------------------------#
# This script adds a scene, where images are displayed.                        #
# You can switch between images using arrow keys.                              #
#------------------------------------------------------------------------------#
# -=[ USAGE ]=-                                                                #
#------------------------------------------------------------------------------#
# To call this scene use this script call:                                     #
# SceneManager.call(Scene_ShowPicture)                                         #
#                                                                              #
# You can use this in many ways:                                               #
# - To show controls                                                           #
# - Make 'HELP' or 'Game Manual'                                               #
# - To show maps etc.                                                          #
# - And many more!                                                             #
#------------------------------------------------------------------------------#
# -=[ INSTRUCTIONS ]=-                                                         #
#------------------------------------------------------------------------------#
# Paste below Materials; above Main.                                           #
# Create images with game resolution (640 x 480) and put them                  #
# in Pictures folder. Filenames and amount of images are configurable below.   #
#------------------------------------------------------------------------------#
# -=[ TERMS OF USE ]=-                                                         #
#------------------------------------------------------------------------------#
# -[ NON-COMMERCIAL use ]-                                                     #
#   Free as long as credit will be given to Rikifive.                          #
# -[ COMMERCIAL use ]-                                                         #
#   Free as long as credit will be given to Rikifive and I'll get a free copy  #
#   of your game. Contact me via RMVXAce Community/RMWeb first.                #
# -[ REPOSTING ]-                                                              #
#   You ARE allowed to repost this script when asking for help on              #
#   RMVXAce Community/RMWeb, but to repost this script anywhere else           #
#   you need to notify me first.                                               #
# -[ EDITING ]-                                                                #
#   You ARE allowed to edit this script to your needs, but to post edited      #
#   version anywhere, you need my permission.                                  #
# -[ PRESERVE THIS HEADER ]-                                                   #
#   Do not remove this header and claim this script as your own.               #
#------------------------------------------------------------------------------#
# -=[ COMPATIBILITY ]=-                                                        #
#------------------------------------------------------------------------------#
# Scene itself is 100% safe, unless you have a script, that uses exactly       #
# the same scene and window names: [Scene_ShowPicture] & [Window_ShowPicture]. #
# Command in menu however, may be incompatible with some menu scripts,         #
# that change the layout of menu and commands. By incompatibility I mean       #
# a missing command of this script, due to simply being overwrited.            #
# It's not a major issue anyway as the command part can be even removed and    #
# configured in these menu scripts, by simply using the scene call.            #
#==============================================================================#

module RK5_567361
  
  #----------------------------------------------------------------------------#
  # -=[ CONFIGURATION ]=-                                                      #
  #----------------------------------------------------------------------------#
  
  # Set the filename.
  FILE_NAME = "Help_"
  
  # Set amount of pictures:
  PICTURES = 3
  
  # File Directories: (Graphics/Pitures/[FILE_NAME][# of PICTURES].png)
  # For example when you have: FILE_NAME = "Help_" and PICTURES = 3
  # then these files are required: Help_1.png ; Help_2.png and Help_3.png
  
  # Set the command name:
  COMMAND_VOCAB = "Help"
  
  #----------------------------------------------------------------------------#
  # END OF CONFIGURATION                                                       #
  #----------------------------------------------------------------------------#
  
end

class Scene_ShowPicture < Scene_MenuBase
 
  def start
    super
    create_image_window
    @picture = 1
  end
 
  def create_image_window
    @image_window = Window_ShowPicture.new
    @image_window.viewport = @viewport
    @image_window.set_handler(:cancel, method(:return_scene))
    @image_window.activate
  end
  
  def update
    super
    if Input.trigger?(:LEFT)
      @picture = @picture == 1 ? RK5_567361::PICTURES : @picture - 1
      Sound.play_cursor
      @image_window.refresh(@picture)
    elsif Input.trigger?(:RIGHT)
      @picture = @picture == RK5_567361::PICTURES ? 1 : @picture + 1
      Sound.play_cursor
      @image_window.refresh(@picture)
    end
  end
      
 
end
 
class Window_ShowPicture < Window_Selectable
 
  def initialize
    super(-12, -12, 664, 504)
    self.opacity = 0
    refresh(picture = 1)
  end
 
  def refresh(picture)
    contents.clear
    
    back = Cache.picture(RK5_567361::FILE_NAME + picture.to_s)
    rect = Rect.new(0,0,back.width,back.height)
    contents.blt(0,0,back,rect,255)
      
  end
end

### ADD A COMMAND OF THAT SCENE TO MENU (before Game End)
class Window_MenuCommand < Window_Command
  alias :add_game_end_command_up :add_game_end_command
  def add_game_end_command
    add_command(RK5_567361::COMMAND_VOCAB, :show_picture)
    add_game_end_command_up
  end
end

class Scene_Menu < Scene_MenuBase
  alias :create_command_window_up :create_command_window
  def create_command_window
    create_command_window_up
    @command_window.set_handler(:show_picture,  method(:command_show_picture))
  end
  
  def command_show_picture
    SceneManager.call(Scene_ShowPicture)
  end
end
#==============================================================================#
# END OF SCRIPT                                                                #
#==============================================================================#