#==============================================================================
# +++ MOG - Battler Shadow (v1.0) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Adiciona uma sombra abaixo do battler, o script tem um efeito melhor se
# usado com o MOG Battler Motion no modo Standby 2.
#==============================================================================
# Para ativar a sombra basta colocar a Tag abaixo na caixa de notas do inimigo.
#==============================================================================
#
# <Shadow = X>
#
# X - Altura da sombra
#
#==============================================================================
module MOG_BATTLER_SHADOW
  # Opacidade da sombra
  SHADOW_OPACITY = 100
  # Ativar o efeito de zoom. (Apenas com o Battler Motion)
  ZOOM_EFFECT = true
end

$imported = {} if $imported.nil?
$imported[:mog_battler_shadow] = true

#==============================================================================
# ■ Game BattlerBase  
#==============================================================================
class Game_BattlerBase
   attr_accessor :shadow_h
end
 
#==============================================================================
# ■ Game Enemy
#==============================================================================
class Game_Enemy < Game_Battler
   
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_bshadow_initialize initialize
  def initialize(index, enemy_id)
      mog_bshadow_initialize(index, enemy_id)
      @shadow_h = enemy.note =~ /<Shadow = (\d+)>/i ? $1 : nil
  end  
  
end

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Init Visibility
  #--------------------------------------------------------------------------  
  alias mog_battler_shadow_init_visibility init_visibility
  def init_visibility
      mog_battler_shadow_init_visibility
      create_battler_shadow if can_create_battler_shadow?
  end
  
  #--------------------------------------------------------------------------
  # ● Can create Battler Shadow
  #--------------------------------------------------------------------------  
  def can_create_battler_shadow?
      return false if @battler.shadow_h == nil
      return false if @bshadow != nil
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Create Battler Shadow
  #--------------------------------------------------------------------------  
  def create_battler_shadow      
      @bshadow = Sprite.new ; @bshadow.bitmap = self.bitmap
      @bshadow.x = self.x ; @bshadow.z = self.z ; @bshadow.y = self.y
      @bshadow.ox = @bshadow.bitmap.width / 2 ;@bshadow.oy = @bshadow.bitmap.height / 2
      @bshadow_h = @battler.shadow_h.to_i ; @bshadow.opacity = 0
      @bshadow_o = MOG_BATTLER_SHADOW::SHADOW_OPACITY
      @bshadow.viewport = self.viewport
      @bshadow.tone = Tone.new(-255, -255,-255,255)
      @bshadow_init = 260 ; @bshadow_z = 1.00 / (@bshadow.bitmap.height * 0.04)
      @bshadow.zoom_y = @bshadow_z ; update_bshadow
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  alias mog_bshadow_dispose dispose
  def dispose
      (@bshadow.bitmap.dispose ; @bshadow.dispose) if @bshadow != nil
      mog_bshadow_dispose      
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Position
  #--------------------------------------------------------------------------  
  alias mog_bshadow_update update
  def update
      mog_bshadow_update
      update_bshadow
  end
  
  #--------------------------------------------------------------------------
  # ● Update bshadow
  #--------------------------------------------------------------------------  
  def update_bshadow
      return if @bshadow == nil
      return if @battler.hidden?
      @bshadow.x = self.x ; @bshadow.z = self.z - 2
      if $imported[:mog_battler_motion]
         update_bshadow_bmotion
      else  
         @bshadow.y = self.y + @bshadow_h
         @bshadow.opacity = self.opacity - @bshadow_init          
         @bshadow_init -= 5 if !@battler.dead? and @bshadow_init > @bshadow_o
         @bshadow.visible = self.visible
         @bshadow.ox = self.ox ; @bshadow.oy = self.oy
      end
      @bshadow_init += 5 if @battler.dead? and @bshadow_init > -260
  end
      
  #--------------------------------------------------------------------------
  # ● Update Bshadow Motion
  #--------------------------------------------------------------------------  
  def update_bshadow_bmotion
      @bshadow.y = self.y + @bshadow_h - @battler.motion_bms[0]
      @bshadow.opacity = self.opacity - @bshadow_init
      @bshadow_init -= 5 if !@battler.dead? and @bshadow_init > @bshadow_o and !@wait_motion_start
      @bshadow.visible = self.visible
      return if !MOG_BATTLER_SHADOW::ZOOM_EFFECT
      @bshadow.zoom_x = 1.00 + (@battler.motion_bms[0] * 0.009)
      @bshadow.zoom_y = @bshadow_z + (@battler.motion_bms[0] * 0.001)
  end
        
end