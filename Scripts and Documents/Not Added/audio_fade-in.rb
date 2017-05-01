%Q(
╔════╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═════╗
║ ╔══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╩═══╗ ║
╠─╣                              Audio Fade In                               ╠─╣
╠─╣                           by RPG Maker Source.                           ╠─╣
╠─╣                          www.rpgmakersource.com                          ╠─╣
║ ╚══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╦═══╝ ║
╠════╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═╤═╩═════╣
║ ┌────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴─────┐ ║
╠─┤ Version 1.0.0                   17/03/15                        DD/MM/YY ├─╣
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
║ • Version 1.0.0, 17/03/15 - (DD/MM/YY).                                      ║
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
║  This script adds the "fade in" function to the Audio channels, since by     ║
║  default, only "fade out" is included as an event command.                   ║
║                                                                              ║
║  It is very easy to use, just add the correct command using a Call Script    ║
║  event command after you use a Play BGM/BGS/ME one.                          ║
║                                                                              ║
║  We hope you enjoy it.                                                       ║
║                                                                              ║
║  Thanks for choosing our products.                                           ║
║                                                                              ║
║ ┌──────────────────────────────────────────────────────────────────────────┐ ║
║ │ ■ Feature Documentation.                                                 │ ║
║ └┬┬┬┬──────────────────────────────────────────────────────────────────┬┬┬┬┘ ║
║                                                                              ║
║  The script commands that you can use inside a Script Call (Event Command)   ║
║  are displayed inside the following chart, followed by their description     ║
║  and, if needed, usage details and examples.                                 ║
║                                                                              ║
║  ┌───────────────────────────────┐                                           ║
║  │ Audio.bgm_fadein(frames)      │                                           ║
║  ├───────────────────────────────┴────────────────────────────────────────┐  ║
║  │ Use right after a Play BGM event command.                              │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║  ┌───────────────────────────────┐                                           ║
║  │ Audio.bgs_fadein(frames)      │                                           ║
║  ├───────────────────────────────┴────────────────────────────────────────┐  ║
║  │ Use right after a Play BGS event command.                              │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║  ┌───────────────────────────────┐                                           ║
║  │ Audio.me_fadein(frames)       │                                           ║
║  ├───────────────────────────────┴────────────────────────────────────────┐  ║
║  │ Use right after a Play ME event command.                               │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
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
# ** Audio
#------------------------------------------------------------------------------
#  The module that carries out music and sound processing.
#==============================================================================
 
module Audio
 
  @bgm_volume = 100
  @bgs_volume = 100
  @me_volume  = 100
  @se_volume  = 100
 
  class << self
   
    #------------------------------------------------------------------------
    # * Public Instance Variables.                                      [NEW]
    #------------------------------------------------------------------------
    attr_reader :bgm_volume, :bgs_volume, :me_volume, :se_volume
   
    ['bgm', 'bgs', 'me', 'se'].each { |channel| class_eval %Q(
 
    #------------------------------------------------------------------------
    # * Alias (BGM/BGS/ME/SE) Play.                                     [NEW]
    #------------------------------------------------------------------------
    alias_method(:ms_audio_original_#{channel}_play, :#{channel}_play)
   
    #------------------------------------------------------------------------
    # * (BGM/BGS/ME/SE) Play.                                           [MOD]
    #------------------------------------------------------------------------
    def #{channel}_play(filename, volume = 100, pitch = 100, pos = 0)
      @now_#{channel} = [filename, volume, pitch, pos]
      volume = @#{channel}_volume * volume / 100
      if pos > 0
        ms_audio_original_#{channel}_play(filename, volume, pitch, pos)
      else
        ms_audio_original_#{channel}_play(filename, volume, pitch)
      end
    end
   
    #------------------------------------------------------------------------
    # * Set (BGM/BGS/ME/SE) Volume.                                     [NEW]
    #------------------------------------------------------------------------
    def #{channel}_volume=(value)
      value = 0   if value < 0
      value = 100 if value > 100
      @#{channel}_volume = value
      #{channel}_play(*@now_#{channel}) if @now_#{channel}
    end)
   
    next if channel == 'se' ; class_eval %Q(
   
    #------------------------------------------------------------------------
    # * (BGM/BGS/ME) Fade-In.                                           [NEW]
    #------------------------------------------------------------------------
    def #{channel}_fadein(frames)
      @#{channel}_fade_step = 100.0 / frames.to_f
      @#{channel}_volume  = 0
    end
   
    #------------------------------------------------------------------------
    # * (BGM/BGS/ME) Update.                                            [NEW]
    #------------------------------------------------------------------------
    def #{channel}_update
      @#{channel}_volume += @#{channel}_fade_step
      #{channel}_play(*@now_#{channel}) if @now_#{channel}
      @#{channel}_fade_step = nil if @#{channel}_volume >= 100.0
    end
   
    #------------------------------------------------------------------------
    # * Alias (BGM/BGS/ME) Fade.                                        [NEW]
    #------------------------------------------------------------------------
    alias_method(:ms_audio_original_#{channel}_fade, :#{channel}_fade)
   
    #------------------------------------------------------------------------
    # * (BGM/BGS/ME) Fade.                                              [MOD]
    #------------------------------------------------------------------------
    def #{channel}_fade(time)
      ms_audio_original_#{channel}_fade(time)
    end)}
   
    #------------------------------------------------------------------------
    # * Update.                                                         [NEW]
    #------------------------------------------------------------------------
    def update
      bgm_update if @bgm_fade_step && @bgm_volume < 100
      bgs_update if @bgs_fade_step && @bgs_volume < 100
      me_update  if @me_fade_step  && @me_volume  < 100
    end
   
  end
 
end
 
#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================
 
class Scene_Base
 
  #--------------------------------------------------------------------------
  # * Alias Update Basic.                                               [NEW]
  #--------------------------------------------------------------------------
  alias_method(:ms_audio_original_update_basic, :update_basic)
 
  #--------------------------------------------------------------------------
  # * Update Basic.                                                     [NEW]
  #--------------------------------------------------------------------------
  def update_basic
    Audio.update
    ms_audio_original_update_basic
  end
 
end