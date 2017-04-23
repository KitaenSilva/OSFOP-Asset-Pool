#==============================================================================
# +++ MOG - Animation + (V2.3) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# - O script adiciona algumas funções extras para apresentar as animações 
# de batalha.
#==============================================================================
# Coloque as tags abaixo na caixa de notas das habilidades ou itens.
#
# ID = ID of Animation.
#
#------------------------------------------------------------------------------
# ● HIT ANIMATION ●
#
# <Hit Animation = ID>
#
#------------------------------------------------------------------------------
# ● WAIT FOR HIT ANIMATION ●
#
# <Wait Hit Animation = ID>
#
#------------------------------------------------------------------------------
# ● USE ANIMATION (TYPE 1) ● 
#
# <Use Animation = ID>
#
#------------------------------------------------------------------------------
# ● USE ANIMATION (TYPE 2) ● (Wait for animation to complete)
#
# <Wait Use Animation = ID>
#
#------------------------------------------------------------------------------
# ● USE ANIMATION (TYPE 3) ● (Wait for animation to complete after action)
#
#  <Wait After Animation = ID>
#
#------------------------------------------------------------------------------
# ● STATES ANIMATION (LOOP) ● (States Tab) 
#
# <Loop Animation = ID>
#
#------------------------------------------------------------------------------
# ● DEATH ANIMATION ● (Enemy or Actor Tab) 
#
# <Death Animation = ID>
#
#------------------------------------------------------------------------------
# ● CAST ANIMATION (TYPE 1) ● 
#
# <Cast Animation = ID>
#
#==============================================================================
module MOG_ANIMATION_PLUS
   # Defina aqui as IDs das animações que irão ignorar o tempo de espera
   # para fluir a batalha, caso contrário o sistema de batalha vai
   # esperar todas as animações sem excessão terminarem para poder prosseguir
   # para o próximo estágio de batalha.
   #
   # É aconselhável colocar as animações das condições nesta opção para evitar
   # que o sistema espere a animação do loop terminar.
   #
   IGNORE_WAIT_TIME_ANIMATION_ID = [1,4,10,69,109,111,114,115,116,117,118,119,120,131,132]
   
   #Velocidade de loop entre as animações. 
   STATES_LOOP_SPEED = 30
   
   #Definição da animação de level UP.
   LEVEL_UP_ANIMATION = 37
   
   #Definição da animação de carregar magia.
   CAST_ANIMATION = 0
end
 
#==============================================================================
# Atualizações desta versão. 
#==============================================================================
# (ver 2.3) - Compatibilidade com MOG Flash Damage.
# (Ver 2.2) - Correção do requerimento do script MOG ATB.
# (Ver 2.1) - Adição da animação de carregar magia.
#           - Correção do bug de ativar loop de animação em battler morto.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_animation_plus] = true

#===============================================================================
# ■ Game Temp
#===============================================================================
class Game_Temp
  
  attr_accessor :ani_plus_wait
  attr_accessor :ani_plus_data
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_ani_plus_initialize initialize
  def initialize
      @ani_plus_wait = false ; @ani_plus_data = [0,0]
      mog_ani_plus_initialize
  end
  
end
#==============================================================================
# ■ Game Battler
#==============================================================================
class Game_Battler < Game_BattlerBase

  attr_accessor :animation_loop
  attr_accessor :cast_ani_data
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_animation_plus_initialize initialize
  def initialize
      mog_animation_plus_initialize
      @animation_loop = []
  end
  
  #--------------------------------------------------------------------------
  # ● Add New State
  #--------------------------------------------------------------------------               
  alias mog_animation_plus_add_new_state add_new_state
  def add_new_state(state_id) 
      mog_animation_plus_add_new_state(state_id)
      check_loop_animation
  end    
  
  #--------------------------------------------------------------------------
  # ● Erase State
  #--------------------------------------------------------------------------             
  alias mog_animation_plus_erase_state erase_state
  def erase_state(state_id)  
      mog_animation_plus_erase_state(state_id)  
      check_loop_animation
  end  
  
  #--------------------------------------------------------------------------
  # ● Check Loop Animation
  #--------------------------------------------------------------------------               
  def check_loop_animation
      @animation_loop.clear
      self.states.each_with_index do |i, index|
      if i.note =~ /<Loop Animation = (\d+)>/i    
         @animation_loop.push([$1.to_i,0, index + 1, true]) 
      end
      end
  end
      
  #--------------------------------------------------------------------------
  # ● Item Apply
  #--------------------------------------------------------------------------           
  alias mog_animation_plus_item_apply item_apply
  def item_apply(user, item)
      mog_animation_plus_item_apply(user, item)
      execute_animation_plus_hit(user, item) if execute_hit_animation?(item)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Hit Animation
  #--------------------------------------------------------------------------           
  def execute_hit_animation?(item)
      return false if !SceneManager.scene_is?(Scene_Battle)
      return false if item.nil?
      return false if !@result.success
      return false if $imported[:mog_skill_ex] and self.flash_damage
      return true
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Animation Plus Hit
  #--------------------------------------------------------------------------           
  def execute_animation_plus_hit(user, item)
      self.animation_id = $1.to_i if item.note =~ /<Hit Animation = (\d+)>/i
      if item.note =~ /<Wait Hit Animation = (\d+)>/i
         self.animation_id = $1.to_i
         animation = $data_animations[$1.to_i] rescue nil
         anid = (animation.frame_max * 4) + 1 if animation != nil
         $game_temp.ani_plus_data[0] = anid if anid != nil
         $game_temp.ani_plus_data[0] -= 20 if $imported[:mog_sprite_actor] and user.is_a?(Game_Actor)
         $game_temp.ani_plus_data[0] = 1 if $game_temp.ani_plus_data[0] < 1
      end
      if self.dead?
         if self.is_a?(Game_Enemy)
            battler = $data_enemies[self.enemy_id]
         else
            battler = $data_actors[self.id]
         end  
         self.animation_id = $1.to_i if battler.note =~ /<Death Animation = (\d+)>/i
      end 
  end
  
end

#==============================================================================
# ■ Sprite_Base
#==============================================================================
class Sprite_Base < Sprite  

  #--------------------------------------------------------------------------
  # ● Battle Animation?
  #--------------------------------------------------------------------------             
  def battle_animation?      
      if @animation != nil
         if MOG_ANIMATION_PLUS::IGNORE_WAIT_TIME_ANIMATION_ID.include?(@animation.id)
            return false
         end
         return true          
      end  
      return false 
  end
  
end  

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Update Position
  #--------------------------------------------------------------------------             
  alias mog_animation_plus_update_position update_position
  def update_position
      mog_animation_plus_update_position
      if loop_animation_base?
         if $imported[:mog_atb_system]
            @battler.cast_ani_data = nil if @battler.atb_cast.empty?
            update_loop_animation_for_cast if !@battler.atb_cast.empty?
         end   
         update_loop_animation_for_states if loop_animation_state?
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Update Position
  #--------------------------------------------------------------------------             
  def update_loop_animation_for_cast
      if @battler.cast_ani_data == nil
         item = @battler.atb_cast[0] rescue nil
         if item != nil and item.note =~ /<Cast Animation = (\d+)>/i ; cast_id = $1.to_i
         else ; cast_id = MOG_ANIMATION_PLUS::CAST_ANIMATION.abs
         end  
         animation = $data_animations[cast_id] rescue nil
         anid = (animation.frame_max * 4) + 1 rescue nil
         @battler.cast_ani_data = [0,cast_id,anid] rescue nil
      end   
      @battler.cast_ani_data[0] += 1
      return if [nil,0].include?(@battler.cast_ani_data[1])
      return if @battler.cast_ani_data[0] < @battler.cast_ani_data[2]
      @battler.cast_ani_data[0] = 0
      @battler.animation_id = @battler.cast_ani_data[1]
  end
  
  #--------------------------------------------------------------------------
  # ● Loop Animation Base
  #--------------------------------------------------------------------------             
  def loop_animation_base?
      return false if self.animation?
      return false if @battler == nil
      return false if @battler.dead?
      return false if $imported[:mog_atb_system] and BattleManager.subject != nil
      if $imported[:mog_battle_hud_ex] 
      return false if $game_message.visible and MOG_BATTLE_HUD_EX::MESSAGE_WINDOW_FADE_HUD
      return false if !$game_temp.battle_hud_visible
      end       
      return false if $imported[:mog_skill_ex] and BattleManager.in_turn?
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Loop Animation State?
  #--------------------------------------------------------------------------             
  def loop_animation_state?
      return false if @battler.animation_loop.empty?
      return false if $imported[:mog_atb_system] and !@battler.atb_cast.empty?
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Update Loop Animation
  #--------------------------------------------------------------------------               
  def update_loop_animation_for_states
      for i in @battler.animation_loop
          next if !i[3]
          i[1] += 1 
          if i[1] >= MOG_ANIMATION_PLUS::STATES_LOOP_SPEED
             i[1] = 0 ; @battler.animation_id = i[0] ; i[3] = false
             if i[2] >= @battler.animation_loop.size
                for i in @battler.animation_loop
                    i[1] = 0 ; i[3] = true
                end                 
            end  
          end
          break           
      end        
  end
  
  #--------------------------------------------------------------------------
  # ● Update Z Correction
  #--------------------------------------------------------------------------                   
  def update_z_correction
      return if !@animation
      @ani_sprites.each do |sprite| sprite.z = self.z + 1 end
  end  
  
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # ● Animation?
  #--------------------------------------------------------------------------                     
  def animation?
      battler_sprites.any? {|sprite| sprite.battle_animation? }
  end  
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # ● Start
  #--------------------------------------------------------------------------
  alias mog_animation_plus_start start
  def start
      $game_party.members.each {|actor| actor.check_loop_animation }    
      mog_animation_plus_start
  end

  #--------------------------------------------------------------------------
  # ● Apply Item
  #--------------------------------------------------------------------------             
  alias mog_aniplus_apply_item_effects apply_item_effects
  def apply_item_effects(target, item)
      mog_aniplus_apply_item_effects(target, item)
      (target.cast_ani_data = nil ; target.animation_loop.clear) if target.hp == 0
  end
  
  #--------------------------------------------------------------------------
  # ● Wait For Animation
  #--------------------------------------------------------------------------             
  alias mog_aniplus_wait_for_animation wait_for_animation
  def wait_for_animation
      update_for_wait while $game_temp.ani_plus_data[0] > 0
      mog_aniplus_wait_for_animation
  end  
  
  #--------------------------------------------------------------------------
  # ● Force Wait for animation
  #--------------------------------------------------------------------------             
  def force_wait_for_animation
      while $game_temp.ani_plus_data[0] > 0 ; $game_temp.ani_plus_data[0] -= 1
            update_basic
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------         
  alias mog_animation_plus_use_item use_item
  def use_item
      $game_temp.ani_plus_wait = false 
      execute_cast_animation unless $imported[:mog_sprite_actor] 
      mog_animation_plus_use_item      
      force_wait_for_animation
  end
 
  #--------------------------------------------------------------------------
  # ● Show User Animation Afer Action
  #--------------------------------------------------------------------------       
  def show_user_animation_afer_action
      item = @subject.current_action.item rescue nil
      return if item.nil?
      if item.note =~ /<After Animation = (\d+)>/i 
         execute_animation(@subject, $1.to_i,false)    
      elsif item.note =~ /<Wait After Animation = (\d+)>/i  
         execute_animation(@subject, $1.to_i,true)    
      end 
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Cast Animation
  #--------------------------------------------------------------------------       
  def execute_cast_animation
      return if !execute_cast_animation?
      item = @subject.current_action.item
      if $imported[:mog_battler_motion] and $imported[:mog_sprite_actor] 
      if (item != nil and item.note =~ /<Hide User>/) 
          @subject.bact_sprite_visiblle = false 
          if @subject.is_a?(Game_Actor) and @cp_members != nil
             @cp_members.each do |battler| battler.bact_sprite_visiblle = false ; end
          end
      end      
      end
      if item.note =~ /<Use Animation = (\d+)>/i 
         execute_animation(@subject, $1.to_i,false)    
      elsif item.note =~ /<Wait Use Animation = (\d+)>/i  
         execute_animation(@subject, $1.to_i,true)    
      end  
  end  
  
  #--------------------------------------------------------------------------
  # ● Execute Cast Animation
  #--------------------------------------------------------------------------       
  def execute_cast_animation?
      item = @subject.current_action.item rescue nil
      return false if item.nil?
      return false if $game_party.all_dead?
      return false if $game_troop.all_dead?
      return true
  end  
  
  #--------------------------------------------------------------------------
  # ● Execute Animation
  #--------------------------------------------------------------------------     
  def execute_animation(subject , anime_id = 0, wait_animation = false)
      return if anime_id <= 0 or subject == nil
      subject.animation_id = anime_id rescue nil
      if $imported[:mog_atb_system] and can_execute_cooperation_skill?
         for battler in current_cp_members
             battler.animation_id = anime_id rescue nil
         end       
      end  
      if wait_animation
         duration = ($data_animations[anime_id].frame_max * 4) + 1
         for i in 0..duration ; update_basic ; $game_temp.ani_plus_wait = true ; end      
      end    
      $game_temp.ani_plus_wait = false
   end  
 
end    

#==============================================================================
# ■ Game Actor
#==============================================================================
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------
  # ● Level UP
  #--------------------------------------------------------------------------       
  alias mog_animation_plus_level_up level_up
  def level_up
       mog_animation_plus_level_up
       self.animation_id = MOG_ANIMATION_PLUS::LEVEL_UP_ANIMATION if can_lvup_animation?
  end

  #--------------------------------------------------------------------------
  # ● Can Lvup Animation
  #--------------------------------------------------------------------------       
  def can_lvup_animation?
      return false if !use_sprite?
      return false if !SceneManager.scene_is?(Scene_Battle)
      if $imported[:mog_battle_hud_ex] 
          return false if $game_message.visible and MOG_BATTLE_HUD_EX::MESSAGE_WINDOW_FADE_HUD
          return false if !$game_temp.battle_hud_visible
      end
      return true
  end

end