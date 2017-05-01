#===============================================================================
# Name: Dark's After Image Effect
# Author: Nhat Nguyen (Dark Sky)
# Released on: May 2nd 2016
#-------------------------------------------------------------------------------
# Version 1.0: Released!
# Version 1.1: Fixed Sprites dispose issues. (Thanks to Sixth)
#-------------------------------------------------------------------------------
# Event's Comment Tag:
# <afterimage: dspeed,dmode>
#   -> dspeed: when event speed = dspeed then afterimage appear!
#   -> dmode: set after image mode!
# ex: <afterimage: 5,3> #At speed 5, Randomly Color After Image Appear! 
#                        FABULOUS!
#-------------------------------------------------------------------------------
# Script call:
# $game_player.afterimage_mode = x #set player's afterimage mode to x
# $game_map.events[id].afterimage_mode = x #set "event id" 's afterimage mode to x
# $game_map.events[id].afterimage_speed = x #set "event id" 's afterimage speed to x
#===============================================================================
module DarkAfterImage
  FADE_SPEED = 5        #FIND OUT YOURSELT PLZ!
  DELAY = 2             #FIND OUT YOURSELT PLZ!
  MODE = 1              #Default Mode
  # MODE 
  # 1 => Normal (Black)
  # 2 => White
  # 3 => Random Color
  CUSTOM_MODE = {} 
  CUSTOM_MODE[4] = Tone.new(0,0,155,0) #Violet
  CUSTOM_MODE[5] = Tone.new(255,0,0,0) #Red
  CUSTOM_MODE[6] = Tone.new(0,100,0,0) #Green
  TOKEN = /<afterimage:\s*(\w+),(\w+)>/i #Don't change this unless you know what
                                         #are you doing.
end
include DarkAfterImage
class Sprite_CharacterAfterImage < Sprite
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(x,y,bitmap,viewport,sprite,mode)
    super(viewport)
    @sprite = sprite
    self.bitmap = bitmap
    self.src_rect.set(@sprite.src_rect)
    if mode == 3
      self.tone = Tone.new(rand(255),rand(255),rand(255),rand(255))
    end
    if mode == 1
      self.tone = Tone.new(0,0,0,200)
    end
    if mode == 2
      self.tone = Tone.new(150,150,150,100)
    end
    if mode > 3
      self.tone = CUSTOM_MODE[mode]
    end
    @src_rect = @sprite.src_rect.clone
    self.x = x
    self.opacity = 200
    self.oy = @sprite.oy
    self.ox = @sprite.ox
    self.y = y
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if !self.disposed?
      self.src_rect.set(@src_rect)
      if self.opacity > 0
        self.opacity -= FADE_SPEED
      end
    end
  end
end
class Game_Player
  attr_accessor :afterimage_mode
end
class Game_Event
  attr_accessor :afterimage_mode
  attr_accessor :afterimage_speed
  attr_accessor :afterimage_delay
  alias :dark_after_image_update_Ev  :update
  def update
    dark_after_image_update_Ev()
    if @afterimage_delay
      if @afterimage_delay > 0
        @afterimage_delay -= 1
      end
    end
  end
end
class Spriteset_Map
  alias :dark_after_image_update  :update
  alias :dark_after_image_initialize  :initialize
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize
    @player_after_image = []
    @player_after_image_trash = []
    @after_image_delay = DELAY
    init_after_image_events
    dark_after_image_initialize()
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  alias dispo_after_effs8383 dispose
  def dispose
    @player_after_image.each {|sp| sp.dispose if sp && !sp.disposed?}
    @player_after_image_trash.each {|sp| sp.dispose if sp && !sp.disposed?}
    dispo_after_effs8383
  end
  #--------------------------------------------------------------------------
  # * Init after image events
  #--------------------------------------------------------------------------
  def init_after_image_events
    @after_events ||= []
    @after_events.clear
    $game_map.events.values.each do |event|
      next if event.list.nil?
      event.list.each do |command|
        next if command.code != 108
        if command.parameters[0] =~ TOKEN
          event.afterimage_speed = $1.to_i
          event.afterimage_mode  = $2.to_i
          event.afterimage_delay = DELAY
          @after_events.push(event)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    dark_after_image_update()
    if @after_image_delay > 0
      @after_image_delay -= 1
    end
    if @after_events
      @after_events.each do |event|
        next if event.move_speed < event.afterimage_speed
        if @character_sprites
          @character_sprites.each do |sprite|
            if sprite.character == event
              if event.afterimage_delay <= 0
                x = sprite.character.screen_x
                y = sprite.character.screen_y
                if event.afterimage_mode
                  mode = event.afterimage_mode
                else
                  mode = MODE
                end
                bitmap = sprite.bitmap
                viewport = sprite.viewport
                @player_after_image.push(Sprite_CharacterAfterImage.new(x,y,bitmap,viewport,sprite,mode))
                event.afterimage_delay = DELAY
              end
            end
          end
        end
      end
    end
    if @player_after_image
      @player_after_image.each do |sprite|
        sprite.update
        if sprite.opacity <= 0
          @player_after_image_trash.push(sprite)
        end
      end
      @player_after_image_trash.each do |sprite|
        sprite.dispose
        @player_after_image.delete(sprite)
      end
      @player_after_image_trash.clear
    end
    if $game_player.dash? && $game_player.moving?
      if @character_sprites
          @character_sprites.each do |sprite|
          if sprite.character == $game_player
            if @after_image_delay <= 0
              x = sprite.character.screen_x
              y = sprite.character.screen_y
              if $game_player.afterimage_mode
                mode = $game_player.afterimage_mode
              else
                mode = MODE
              end
              bitmap = sprite.bitmap
              viewport = sprite.viewport
              @player_after_image.push(Sprite_CharacterAfterImage.new(x,y,bitmap,viewport,sprite,mode))
              @after_image_delay = DELAY
            end
          end
        end
      end
    end
  end
end