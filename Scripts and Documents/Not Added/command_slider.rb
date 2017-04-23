%Q(
╔════╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═════╗
║ ╔══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╗ ║
╠─╣                              Command Slider                              ╠─╣
╠─╣                           by RPG Maker Source.                           ╠─╣
╠─╣                          www.rpgmakersource.com                          ╠─╣
║ ╚══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╝ ║
╠════╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═════╣
║ ┌────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴─────┐ ║
╠─┤ Version 1.2.0                   28/04/15                        DD/MM/YY ├─╣
║ └────┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬─────┘ ║
╠══════╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══╧═══════╣
║                                                                              ║
║               This work is protected by the following license:               ║
║     ╔══════════════════════════════════════════════════════════════════╗     ║
║     │                                                                  │     ║
║     │ Copyright © 2014 Maker Systems.                                  │     ║
║     │                                                                  │     ║
║     │ This software is provided 'as-is', without any kind of           │     ║
║     │ warranty. Under no circumstances will the author be held         │     ║
║     │ liable for any damages arising from the use of this software.    │     ║
║     │                                                                  │     ║
║     │ Permission is granted to anyone to use this software on their    │     ║
║     │ free or commercial games made with a legal copy of RPG Maker     │     ║
║     │ VX Ace, as long as Maker Systems - RPG Maker Source is           │     ║
║     │ credited within the game.                                        │     ║
║     │                                                                  │     ║
║     │ Selling this code or any portions of it 'as-is' or as part of    │     ║
║     │ another code, is not allowed.                                    │     ║
║     │                                                                  │     ║
║     │ The original header, which includes this copyright notice,       │     ║
║     │ must not be edited or removed from any verbatim copy of the      │     ║
║     │ sotware nor from any edited version.                             │     ║
║     │                                                                  │     ║
║     ╚══════════════════════════════════════════════════════════════════╝     ║
║                                                                              ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 1. VERSION HISTORY.                                                        ▼ ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║ • Version 1.0.0, 24/11/14 - (DD/MM/YY).                                      ║
║                                                                              ║
║ • Version 1.0.1, 28/11/14 - (DD/MM/YY).                                      ║
║                                                                              ║
║ • Version 1.1.0, 28/11/14 - (DD/MM/YY).                                      ║
║   - You can now exclude some windows from the cool sliding effect club.      ║
║                                                                              ║
║ • Version 1.1.1, 29/11/14 - (DD/MM/YY).                                      ║
║                                                                              ║
║ • Version 1.2.0, 28/04/15 - (DD/MM/YY).                                      ║
║   - Changed method structure for better compatibility.                       ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
╠══════════════════════════════════════════════════════════════════════════════╣
║ 2. USER MANUAL.                                                            ▼ ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║ ┌──────────────────────────────────────────────────────────────────────────┐ ║
║ │ ■ Introduction.                                                          │ ║
║ └┬┬┬┬──────────────────────────────────────────────────────────────────┬┬┬┬┘ ║
║                                                                              ║
║  Hello there! This script is "plug and play", you can simply insert it into  ║
║  your project and it will perform flawlessly.                                ║
║                                                                              ║
║  This script will add a nice effect to the selection of items inside your    ║
║  menu and works for all Window_Command windows.                              ║
║                                                                              ║
║  The effect is simple: when an item is selected, its text is smoothly        ║
║  centered inside the selection rectangle, when selecting other item, the     ║
║  last selected item will smoothly move back to its original position.        ║
║                                                                              ║
║  We hope you enjoy it.                                                       ║
║                                                                              ║
║  Thanks for choosing our products.                                           ║
║                                                                              ║
║ ┌──────────────────────────────────────────────────────────────────────────┐ ║
║ │ ■ Configuration.                                                         │ ║
║ └┬┬┬┬──────────────────────────────────────────────────────────────────┬┬┬┬┘ ║
║                                                                              ║
║  "How do I change the speed of the effect?"                                  ║
║  Right click anywhere in the script editor and select "Find" (or CTRL + F)   ║
║  search for "DELAY_LEVEL" (without quotation marks).                         ║
║                                                                              ║
║  You will see something like "DELAY_LEVEL = 4"                               ║
║                                                                              ║
║  Set the number after the equality sign to any numer you like, bigger or     ║
║  equal than 1. The bigger the number, the stronger the deceleration effect   ║
║  and thus the slower the item text moves. Small numbers result in a faster   ║
║  deceleration, default value is 4.                                           ║
║                                                                              ║
║  "How do I exclude some Window from the effect?"                             ║
║  Right click anywhere in the script editor and select "Find" (or CTRL + F),  ║
║  searh for "EXCLUDE" (without quotation marks).                              ║
║                                                                              ║
║  You will see something like:                                                ║
║  "EXCLUDE = 'Window_ExcludedWindow'"                                         ║
║                                                                              ║
║  To exclude Windows from the effect, simply add their names between those    ║
║  single quotes (the name of the class).                                      ║
║  For example, to exclude the Menu Command Window:                            ║
║                                                                              ║
║  EXCLUDE = 'Window_MenuCommand Window_ExcludedWindow'                        ║
║                                                                              ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
╠══════════════════════════════════════════════════════════════════════════════╣
║ 3. NOTES.                                                                  ▼ ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  Have fun and enjoy!                                                         ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
╠══════════════════════════════════════════════════════════════════════════════╣
║ 4. CONTACT.                                                                ▼ ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  Keep in touch with us and be the first to know about new releases:          ║
║                                                                              ║
║  www.rpgmakersource.com                                                      ║
║  www.facebook.com/RPGMakerSource                                             ║
║  www.twitter.com/RPGMakerSource                                              ║
║  www.youtube.com/user/RPGMakerSource                                         ║
║                                                                              ║
║  Get involved! Have an idea for a system? Let us know.                       ║
║                                                                              ║
║  Spread the word and help us reach more people so we can continue creating   ║
║  awesome resources for you!                                                  ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝)
 
#==============================================================================
# ** MakerSystems
#------------------------------------------------------------------------------
#  Module for our Systems.
#==============================================================================
 
module MakerSystems
 
  #============================================================================
  # ** CommandSlider
  #----------------------------------------------------------------------------
  #  Module for Smooth Cursor.
  #============================================================================
 
  module CommandSlider
   
    #------------------------------------------------------------------------
    # * Low values yield a fast effect.                                 [OPT]
    #------------------------------------------------------------------------
    DELAY_LEVEL = 4
    #------------------------------------------------------------------------
    # * Window classes that you don't want to have the effect.          [OPT]
    #------------------------------------------------------------------------
    EXCLUDE = 'Window_ExcludedWindow'
   
  end
 
end
 
#==============================================================================
# ** Window_Command
#------------------------------------------------------------------------------
#  Draw Item replaced.
#==============================================================================
 
class Window_Command < Window_Selectable
 
  #--------------------------------------------------------------------------
  # * Draw Item.                                                        [REP]
  #--------------------------------------------------------------------------
  def draw_item(index)
    # Text for this Command.
    string = command_name(index)
    # Correct font color.
    change_color(normal_color, command_enabled?(index))
    # Command Slide processing only if needed.
    if visible_line_number == 1 || alignment == 1 || alignment == 2 ||
      MakerSystems::CommandSlider::EXCLUDE =~ /#{self.class.name}/
      draw_text(item_rect_for_text(index), string, alignment)
    else
      # Update placement if needed.
      update_placement if respond_to?(:update_placement)
      # Container for the Commands.
      @ms_command_slider ||= []
      return if @ms_command_slider.any? { |command| command[4] == index }
      # Get Rect for this command.
      rect = item_rect_for_text(index)
      # Create Sprite and its Bitmap for this command.
      sprite = Sprite.new(self.viewport)
      sprite.z = self.z + 10
      sprite.bitmap = Bitmap.new(rect.width, rect.height)
      sprite.bitmap.font = contents.font
      # Position Offset for this Command.
      offset_x = rect.x + standard_padding
      offset_y = rect.y + standard_padding
      # Target X for this Command.
      target_x = (rect.width - self.contents.text_size(string).width) / 2
      # Sets Sprite position.
      sprite.x = self.x + offset_x
      sprite.y = self.y + offset_y
      if self.height < fitting_height(visible_line_number)
        if sprite.y < self.y || sprite.y + sprite.bitmap.height >
            self.y + self.height - standard_padding
          sprite.visible = false
        end
      end
      # Draws Command text.
      sprite.bitmap.draw_text(0, 0, rect.width, rect.height, string, alignment)
      # Pushes Command to Commands container.
      @ms_command_slider << [sprite, offset_x, offset_y, target_x, index, 0,
                             sprite.bitmap.text_size(string).width > self.width]
    end
  end
  #--------------------------------------------------------------------------
  # * Set Openness.                                                     [MOD]
  #--------------------------------------------------------------------------
  def openness=(value)
    # Superclass method.
    super(value)
    # Keeps Commands from being visible until Window is opened.
    if @ms_command_slider
      @ms_command_slider.each { |obj| obj[0].visible = self.openness == 255 }
    end
  end
  #--------------------------------------------------------------------------
  # * Alias Update.                                                     [NEW]
  #--------------------------------------------------------------------------
  alias_method(:ms_command_slider_original_update, :update)
  #--------------------------------------------------------------------------
  # * Update.                                                           [MOD]
  #--------------------------------------------------------------------------
  def update
    # Original method.
    ms_command_slider_original_update
    # Update Command Slider.
    ms_command_slider_update
  end
  #--------------------------------------------------------------------------
  # * Command Slider Update.                                            [NEW]
  #--------------------------------------------------------------------------
  def ms_command_slider_update
    # Updates Command Slider if needed.
    if visible_line_number != 1 && @ms_command_slider
      # Goes through each Sprite command data.
      @ms_command_slider.each do |command|
        # Get Sprite.
        sprite   = command[0]
        # Get Offsets.
        offset_x = command[1]
        offset_y = command[2]
        # Get target X.
        target_x = command[3]
        # Get the index that the Sprite represents.
        c_index  = command[4]
        # Current mod to X.
        mod_x    = command[5]
        # Correct target X.
        target_x = c_index == self.index && !command[6] ? target_x : 0
        # Shortcut to DELAY_LEVEL.
        delay = MakerSystems::CommandSlider::DELAY_LEVEL
        # Calculates and applies step value to current mod X.
        step = (target_x - mod_x).to_f / delay
        mod_x += target_x > mod_x ? step.ceil : step.floor
        # Updates Sprite.
        if sprite.viewport != self.viewport
          sprite.viewport = self.viewport
        end
        sprite.x       = self.x - self.ox + offset_x + mod_x
        sprite.y       = self.y - self.oy + offset_y        
        sprite.z       = self.z + 1
        sprite.visible = self.openness == 255
        if self.height < fitting_height(visible_line_number)
          if sprite.y < self.y || sprite.y + sprite.bitmap.height >
             self.y + self.height - standard_padding
            sprite.visible = false
          end
        end
        # Updates command data to account for mod X changes.
        command[5] = mod_x
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Alias Set X.                                                      [NEW]
  #--------------------------------------------------------------------------
  alias_method(:ms_command_slider_original_set_x, :x=)
  #--------------------------------------------------------------------------
  # * Set X.                                                            [MOD]
  #--------------------------------------------------------------------------
  def x=(value)
    ms_command_slider_original_set_x(value)
    ms_command_slider_update
  end
  #--------------------------------------------------------------------------
  # * Alias Set Y.                                                      [NEW]
  #--------------------------------------------------------------------------
  alias_method(:ms_command_slider_original_set_y, :y=)
  #--------------------------------------------------------------------------
  # * Set Y.                                                            [MOD]
  #--------------------------------------------------------------------------
  def y=(value)
    ms_command_slider_original_set_y(value)
    ms_command_slider_update
  end
  #--------------------------------------------------------------------------
  # * Alias Dispose.                                                    [NEW]
  #--------------------------------------------------------------------------
  alias_method(:ms_command_slider_original_dispose, :dispose)
  #--------------------------------------------------------------------------
  # * Dispose.                                                          [MOD]
  #--------------------------------------------------------------------------
  def dispose
    # Original method.
    ms_command_slider_original_dispose
    # Dispose Command Slider.
    ms_command_slider_dispose
  end
  #--------------------------------------------------------------------------
  # * Command Slider Dispose.                                           [NEW]
  #--------------------------------------------------------------------------
  def ms_command_slider_dispose
    # Disposes Command Slider if needed.
    if @ms_command_slider
      @ms_command_slider.each do |command|
        command[0].bitmap.dispose
        command[0].dispose
        command.clear
      end
      @ms_command_slider = nil
    end
  end
 
end
 
#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================
 
class Window_MenuCommand < Window_Command
 
  #--------------------------------------------------------------------------
  # * Alias Select Last.                                                [NEW]
  #--------------------------------------------------------------------------
  alias_method(:ms_command_slider_original_select_last, :select_last)
  #--------------------------------------------------------------------------
  # * Select Last.                                                      [MOD]
  #--------------------------------------------------------------------------
  def select_last
    ms_command_slider_original_select_last
    update
  end
 
end