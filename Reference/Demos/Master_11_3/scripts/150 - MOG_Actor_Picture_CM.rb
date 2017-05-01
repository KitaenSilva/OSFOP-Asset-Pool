#==============================================================================
# +++ MOG - ACTOR PICTURE CM  (v2.1) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Apresenta a imagem do personagem durante a seleção de comandos, com efeitos
# animados.
#==============================================================================
# ● Definindo o nome das imagens dos battlers. 
#==============================================================================
# 1 - As imagens devem ser gravadas na pasta 
#
# GRAPHICS/PICTURES
#
# 2 - Nomeie os  arquivos de imagens da seguinte forma.
#
# 
# ACTOR + ID
#
# EG
#
# ACTOR1.png
#
#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v2.1 - Melhoria na codificação.
# v2.0 - Correção de não atualizar as imagens dos battlers quando se
#        adiciona ou remove um battler no meio da batalha.
#==============================================================================
module MOG_ACTOR_PICTURE_CM 
  #Posição da imagem do battler. (Para fazer ajustes)
  PICTURE_POSITION = [0, 0]  
  
  #Definição da opacidade da imagem.
  PICTURE_OPACITY = 255
  
  #Velocidade de deslize
  SLIDE_SPEED = 40
  
  #Ativar o efeito da imagem respirando.
  BREATH_EFFECT = true
  
  #Definição da prioridade  da imagem na tela.
  PICTURE_PRIORITY_Z = 101
end

$imported = {} if $imported.nil?
$imported[:actor_picture_cm] = true

#===============================================================================
# ■ Game Temp
#===============================================================================
class Game_Temp
  
  attr_accessor :bpicture_cm_need_refresh
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_battler_cm_initialize initialize
  def initialize
      @bpicture_cm_need_refresh = false
      mog_battler_cm_initialize
  end
  
end

#===============================================================================
# ■ Sprite_Battler_CM
#===============================================================================
class Sprite_Battler_CM < Sprite
  include MOG_ACTOR_PICTURE_CM 
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  def initialize(viewport = nil,battler_id = -1)
      super(viewport)
      filename = "Actor" + battler_id.to_s
      self.bitmap = Cache.picture(filename) rescue nil
      self.bitmap = Cache.picture("") if self.bitmap == nil
      sc = (Graphics.width / 2)  - (self.bitmap.width / 2) + PICTURE_POSITION[0]
      @size = [self.bitmap.width + PICTURE_POSITION[0] ,sc]      
      self.visible = false ;  self.opacity = 0 ; self.z = PICTURE_PRIORITY_Z
      self.ox = 0 ; self.oy = self.bitmap.height ; self.x = -@size[0]
      self.y = (Graphics.height + 10) + PICTURE_POSITION[1] ; @cm_visible = false   
      @breach_effect = [1.0,0] ; @battler_id = battler_id  ; @active =  false  
  end  
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  def dispose
      super
      self.bitmap.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  def update
      super
      update_slide
  end  
  
  #--------------------------------------------------------------------------
  # ● Active Battler
  #--------------------------------------------------------------------------      
  def active_battler(battler_id) 
      @active = @battler_id == battler_id ? true : false
      self.visible = true if @active ; @cm_visible = false if !@active 
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh Battler CM
  #--------------------------------------------------------------------------        
  def refresh_battler(cm_visible, battler_index)
      @cm_visible = cm_visible
      active_battler(battler_index)
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Slide
  #--------------------------------------------------------------------------  
  def update_slide      
      if !@cm_visible
           self.x -= SLIDE_SPEED if self.x > -@size[0] 
           self.opacity -= 25
           if self.x <= -@size[0] or self.opacity == 0
              self.visible = false ; self.opacity = 0 ; self.x = -@size[0]
           end   
        else
           self.x += SLIDE_SPEED if self.x < @size[1] 
           self.x = @size[1] if self.x > @size[1] 
           self.opacity += 10 if self.opacity < PICTURE_OPACITY 
           self.opacity = PICTURE_OPACITY if self.opacity > PICTURE_OPACITY 
           update_breath_effect
      end         
      self.visible = false if can_force_hide?
  end
  
  #--------------------------------------------------------------------------
  # ● Can Force Hide
  #--------------------------------------------------------------------------  
  def can_force_hide?
      return true if $game_temp.blitz_commands_phase if $imported[:mog_blitz_commands]
      return true if $game_temp.chain_action_phase if $imported[:mog_active_chain]
      return false
  end
       
  #--------------------------------------------------------------------------
  # ● Update Breath Effect
  #--------------------------------------------------------------------------    
  def update_breath_effect
      return if !BREATH_EFFECT
      @breach_effect[1] += 1
      case @breach_effect[1]
         when 0..30 ; @breach_effect[0] += 0.0004
         when 31..50 ; @breach_effect[0] -= 0.0004
         else ; @breach_effect[1] = 0 ; @breach_effect[0] = 1.truncate
      end
      self.zoom_y = @breach_effect[0]
  end  
  
  #--------------------------------------------------------------------------
  # ● Force Hide
  #--------------------------------------------------------------------------    
  def force_hide
      @cm_visible = false ; self.visible = false ; self.x = -@size[0]
      self.opacity = 0
  end
  
end

#===============================================================================
# ■ Spriteset_Battle
#===============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # ● Create Actors
  #--------------------------------------------------------------------------    
  alias mog_battler_cm_create_actors create_actors
  def create_actors
      mog_battler_cm_create_actors
      create_battler_pictures
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------    
  alias mog_battler_cm_dispose dispose 
  def dispose
      mog_battler_cm_dispose
      dispose_battler_cm
  end  

  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------    
  alias mog_battler_cm_update update
  def update
      mog_battler_cm_update
      update_battler_cm
  end    

  #--------------------------------------------------------------------------
  # ● Create Battler Pictures
  #--------------------------------------------------------------------------    
  def create_battler_pictures
      @battler_pictures = []
      for i in $game_party.battle_members
          @battler_pictures.push(Sprite_Battler_CM.new(nil,i.id))
      end    
  end   
  
  #--------------------------------------------------------------------------
  # ● Dispose Battler CM
  #--------------------------------------------------------------------------    
  def dispose_battler_cm
      return if @battler_pictures == nil
      @battler_pictures.each {|sprite| sprite.dispose if sprite != nil }
  end  
 
  #--------------------------------------------------------------------------
  # ● Update Battler CM
  #--------------------------------------------------------------------------    
  def update_battler_cm
      refresh_battler_cm if $game_temp.bpicture_cm_need_refresh
      return if @battler_pictures == nil
      @battler_pictures.each {|sprite| sprite.update }
  end    
     
  #--------------------------------------------------------------------------
  # ● Update CM Pictures
  #--------------------------------------------------------------------------      
  def update_cm_picture(cm_visible, battler_index)
      return if @battler_pictures == nil
      @battler_pictures.each {|sprite| sprite.refresh_battler(cm_visible, battler_index) }
  end  
  
  #--------------------------------------------------------------------------
  # ● CM Force Hide
  #--------------------------------------------------------------------------      
  def cm_force_hide
      return if @battler_pictures == nil
      @battler_pictures.each {|sprite| sprite.force_hide }
  end  
    
  #--------------------------------------------------------------------------
  # ● Refresh Battler CM
  #--------------------------------------------------------------------------      
  def refresh_battler_cm
      $game_temp.bpicture_cm_need_refresh = false
      dispose_battler_cm ; create_battler_pictures
  end
  
end

#===============================================================================
# ■ Scene_Battle
#===============================================================================
class Scene_Battle < Scene_Base
  
 if $imported["YEA-CommandEquip"]
 #--------------------------------------------------------------------------
 # * Command Equip
 #--------------------------------------------------------------------------   
  alias mog_yfcm_command_equip command_equip
  def command_equip
      @spriteset.cm_force_hide
      mog_yfcm_command_equip
  end 
  end  
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------        
  alias mog_cm_picture_update_basic update_basic
  def update_basic
      mog_cm_picture_update_basic
      update_picture_visible
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Battler CM Active
  #--------------------------------------------------------------------------      
  def update_picture_visible
      return if @actor_command_window.nil?
      cm_visible = can_cm_picture_visible?      
      cm_id = BattleManager.actor.id rescue -1
      @spriteset.update_cm_picture(cm_visible, cm_id)
  end  
  
  #--------------------------------------------------------------------------
  # ● Can CM Picture Visible
  #--------------------------------------------------------------------------        
  def can_cm_picture_visible?
      if $imported[:mog_atb_system]
          return false if $game_system.atb_type != 0
          return false if $game_message.visible
          return false if $game_temp.battle_end
          return false if $game_temp.end_phase_duration[1] > 0
      end
      return false if $imported[:mog_active_chain] and $game_temp.active_chain  
      return false if $imported[:mog_blitz_commands] and $game_temp.blitz_commands_phase
      return false if @party_command_window.active
      return false if BattleManager.actor.nil?
      return false if @actor_window.active
      return false if @enemy_window.active
      return true if @actor_command_window.active
      return true if @item_window.active
      return true if @skill_window.active
      return false
  end  
  
end

#==============================================================================
# ** Game Interpreter
#==============================================================================
class Game_Interpreter
  
 #--------------------------------------------------------------------------
 # ● Command_129
 #--------------------------------------------------------------------------
 alias mog_bpic_cm_command_129 command_129
 def command_129
     mog_bpic_cm_command_129
     $game_temp.bpicture_cm_need_refresh = true if SceneManager.scene_is?(Scene_Battle)
 end
  
 #--------------------------------------------------------------------------
 # ● Command 335
 #--------------------------------------------------------------------------
 alias mog_bpic_cm_command_335 command_335
 def command_335
     mog_bpic_cm_command_335
     $game_temp.bpicture_cm_need_refresh = true if SceneManager.scene_is?(Scene_Battle)
 end 
 
end

#==============================================================================
# ** Game Party
#==============================================================================
class Game_Party < Game_Unit
    
 #--------------------------------------------------------------------------
 # ● Swap Order
 #--------------------------------------------------------------------------
 alias mog_bpic_cm_swap_order swap_order
 def swap_order(index1, index2)
      mog_bpic_cm_swap_order(index1, index2)
      $game_temp.bpicture_cm_need_refresh = true if SceneManager.scene_is?(Scene_Battle)
 end  
  
end