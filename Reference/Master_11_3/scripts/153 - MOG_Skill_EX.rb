#==============================================================================
# +++ MOG - Skill EX (v1.4) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# O script adiciona novas funções para criar habilidades complexas.
# O que inclúi a possibilidade de criar habilidades usando os eventos comuns,
# assim como ativar livremente o sistema de dano usando o comando de eventos.
#==============================================================================

#==============================================================================
# ● FLASH DAMAGE
#==============================================================================
# Basta ativar a função FLASH no alvo para causar o dano no alvo.
# É possível ativar o dano inumeras vezes durante a mesma animação.
#==============================================================================
module MOG_FLASH_DAMAGE
  #Definição das animações que terão o efeito de Flash Damage.
  FLASH_DAMAGE_ANIMATION_ID = [12,72,88,135,137,140,142,148,153]
end

#==============================================================================
# ● PROJECTILE
#==============================================================================
# Essa função permite ativar um projétil com o movimento do usuário até o
# alvo, ou vice-versa. É possível ainda ativar uma animação no projétil.
#==============================================================================
# Use uma das Tags abaixo para ativar o projétil, é possível usar nas
# habilidades, itens e armas.
#
# <Projectile>
# Lança um projétil com o gráfico do ícone da habilidade
#
# <Projectile R>
# O mesmo acima com trajetória inversa.
#
# <Projectile = ID>
# Ativa um projétil com uma animação.(ID = Id da animação)
#
# <Projectile R = ID>
# O mesmo acima com trajetória inversa.
#
# <Projectile S = NAME>
# Lança um projétil com o gráfico NAME (É necessário ter o gráfico na pasta
# Graphics/Projectile/), Essa função é útil para criar arco e flexas.
#
#==============================================================================

#==============================================================================
# ● FADE EFFECT
#==============================================================================
#
# <Fade Background>
# Use a tag acima para ocultar o background.
#
# <Hide Allies>
# Use a tag acima para ocultar os aliados.
#
# <Hide Enemies>
# Use a tag acima para ocultar os inimigos.
#
# <Hide User A>
# Use a tag acima para ocultar o usuário
#
#==============================================================================

#==============================================================================
# ● PLAY MOVIE
#==============================================================================
# Use a Tag Abaixo para ativar um filme.
#
# <Play Movie = MOVIE_NAME>
#
#==============================================================================

#==============================================================================
# ● EVENT COMMANDS
#==============================================================================
# Use os comandos abaixo através comando chamar script
#
# ● battler_damage
# Ativa o dano ou o efeito da ação (É possível utilizar infinitas vezes)
#
# ● fade_background(X)
# Ativa ou desativa o fade no imagem de fundo.
#
# ● hide_allies(X)
# ● hide_enemies(X)
# ● hide_user(X)
# Use um dos comandos acima para ocultar os battlers.
#
#==============================================================================

#==============================================================================
# HISTÓRICO
#==============================================================================
# v1.4 - Correção do bug no efeito Counter.
# v1.3 - Correção na opacidade da animação em alvos mortos.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_skill_ex] = true

#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  
  @subject_user = nil
  
  #--------------------------------------------------------------------------
  # ● Set Subject User
  #-------------------------------------------------------------------------- 
  def self.set_subject_user(subject)
      @subject_user = subject
  end  
    
  #--------------------------------------------------------------------------
  # ● Subject User
  #-------------------------------------------------------------------------- 
  def self.subject_user
      @subject_user
  end
  
end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  attr_accessor :flash_dmg_log
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #-------------------------------------------------------------------------- 
  alias mog_flash_damage_temp_initialize initialize
  def initialize
      @flash_dmg_log = [false,0,nil, nil,nil]
      mog_flash_damage_temp_initialize
  end
  
end

#==============================================================================
# ■ Game Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  attr_accessor :flash_damage
  attr_accessor :pre_target
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #-------------------------------------------------------------------------- 
  alias mog_flash_damage_initialize initialize
  def initialize
      @flash_damage = false
      mog_flash_damage_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● Item Apply
  #-------------------------------------------------------------------------- 
  alias mog_skill_ex_item_apply item_apply
  def item_apply(user, item) 
      mog_skill_ex_item_apply(user, item)
      if self.flash_damage
         perform_collapse_effect if self.dead?
         perform_damage_effect if @result.hp_damage > 0
      end
  end  
  
end

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● Battler Damage
  #-------------------------------------------------------------------------- 
  def battler_damage
      execute_battler_damage(nil,false)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Battler Damage
  #-------------------------------------------------------------------------- 
  def execute_battler_damage(battler = nil,animation = false)
      battler = BattleManager.subject_user rescue nil if battler.nil?
      item = BattleManager.subject_user.current_action.item rescue nil
      execute_flash_damage(item,battler,animation) if execute_battler_damage?(item,battler)
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Battler Damage?
  #-------------------------------------------------------------------------- 
  def execute_battler_damage?(item,battler)
      return false if item.nil? 
      return false if battler.nil?
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Flash Damage
  #-------------------------------------------------------------------------- 
  def execute_flash_damage(item,battler,animation)
      targets = BattleManager.subject_user.current_action.make_targets.compact
      targets.each do |t|
      t.flash_damage = true ; next if t.dead? 
      if [2,8,10].include?(item.scope) and animation
         item.repeats.times { invoke_item_ani(t, item) } if t == battler 
      else   
         item.repeats.times { invoke_item_ani(t, item) }
      end  
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Invoke Item Ani
  #-------------------------------------------------------------------------- 
  def invoke_item_ani(target, item)
      if rand < target.item_cnt(BattleManager.subject_user, item)
         invoke_counter_attack_ani(target, item)
      elsif rand < target.item_mrf(BattleManager.subject_user, item)
         invoke_magic_reflection_ani(target, item)
      else
         apply_item_effects_ani(apply_substitute_ani(target, item), item)
      end
      BattleManager.subject_user.last_target_index = target.index
  end
  
  #--------------------------------------------------------------------------
  # ● Apply Skill/Item Effect
  #--------------------------------------------------------------------------
  def apply_item_effects_ani(target, item)
      target.item_apply(BattleManager.subject_user, item)
      $game_temp.flash_dmg_log = [true,0,target, item,nil] 
  end  
  
  #--------------------------------------------------------------------------
  # ● Invoke Counterattack
  #--------------------------------------------------------------------------
  def invoke_counter_attack_ani(target, item)
      $game_temp.flash_dmg_log = [true,1,target, item,nil] 
      attack_skill = $data_skills[target.attack_skill_id]
      BattleManager.subject_user.last_target_index.item_apply(target, attack_skill)
      $game_temp.flash_dmg_log = [true,2,target, item,attack_skill]
  end  
  
  #--------------------------------------------------------------------------
  # ● Invoke Magic Reflection
  #--------------------------------------------------------------------------
  def invoke_magic_reflection_ani(target, item)
      return if BattleManager.subject_user.nil?
      BattleManager.subject_user.magic_reflection = true
      $game_temp.flash_dmg_log = [true,3,target, item,nil]  
      apply_item_effects_ani(BattleManager.subject_user, item)
      BattleManager.subject_user.magic_reflection = false
  end  

  #--------------------------------------------------------------------------
  # ● Apply Substitute
  #--------------------------------------------------------------------------
  def apply_substitute_ani(target, item)
      if check_substitute_ani(target, item)
          substitute = target.friends_unit.substitute_battler
          if substitute && target != substitute
          $game_temp.flash_dmg_log = [true,4,target, item,substitute]
          return substitute
        end
      end
      target
  end  
  
  #--------------------------------------------------------------------------
  # ● Check Substitute Condition
  #--------------------------------------------------------------------------
  def check_substitute_ani(target, item)
      target.hp < target.mhp / 4 && (!item || !item.certain?)
  end    
  
end

#==============================================================================
# ■ Sprite Base
#==============================================================================
class Sprite_Base < Sprite
  
  #--------------------------------------------------------------------------
  # ● Flash
  #-------------------------------------------------------------------------- 
  alias mog_damage_animation_flash flash 
  def flash(flash_color,flash_duration)
      mog_damage_animation_flash(flash_color,flash_duration)
      item = BattleManager.subject_user.current_action.item rescue nil
      $game_troop.interpreter.execute_battler_damage(@battler,true) if can_execute_flash_damage?(item)
  end
  
  #--------------------------------------------------------------------------
  # ● Can Execute Flash Damage?
  #-------------------------------------------------------------------------- 
  def can_execute_flash_damage?(item)
      return false if item.nil?
      return false if @battler.nil?
      return false if @animation.nil?
      return false if !MOG_FLASH_DAMAGE::FLASH_DAMAGE_ANIMATION_ID.include?(@animation.id)
      return false if BattleManager.subject_user.nil?
      return false if !$game_temp.prj_data[1].nil?
      return true
  end
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Execute Action
  #-------------------------------------------------------------------------- 
  alias mog_damage_animation_execute_action execute_action
  def execute_action
      BattleManager.set_subject_user(@subject)
      mog_damage_animation_execute_action
  end
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #-------------------------------------------------------------------------- 
  alias mog_flash_damage_use_item use_item
  def use_item
      mog_flash_damage_use_item
      tbrs = $game_troop.members + $game_party.battle_members
      tbrs.each do |battler| ; battler.flash_damage = false ; end      
  end
  
  #--------------------------------------------------------------------------
  # ● Turn End
  #-------------------------------------------------------------------------- 
  alias mog_damage_animation_turn_end turn_end
  def turn_end
      mog_damage_animation_turn_end
      BattleManager.subject_user.flash_damage = false if !BattleManager.subject_user.nil?
      BattleManager.set_subject_user(nil)
      $game_temp.flash_dmg_log = [false,0,nil, nil,nil]
  end
  
  #--------------------------------------------------------------------------
  # ● Invoke Item
  #-------------------------------------------------------------------------- 
  alias mog_flash_damage_invoke_item invoke_item
  def invoke_item(target, item)
      return if target.flash_damage
      mog_flash_damage_invoke_item(target, item)
  end
  
 #--------------------------------------------------------------------------
 # ● Refresh Log Window Flash Damage (* update_basic)
 #-------------------------------------------------------------------------- 
 def refresh_log_window_flash_damage
     @log_window.clear
     $game_temp.flash_dmg_log[0] = false ; data = $game_temp.flash_dmg_log
     case data[1]
       when 0
          refresh_status
          @log_window.display_action_results(data[2], data[3])
       when 1
          @log_window.display_counter(data[2], data[3])
       when 2
          refresh_status
          @log_window.display_action_results(BattleManager.subject_user, data[4])
       when 3    
          @log_window.display_reflection(data[2], data[3])
       when 4    
          @log_window.display_substitute(data[4], data[2])   
     end
  end
  
end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
 
  attr_accessor :prj_data
  
  alias mog_prj_initialize initialize
  def initialize
      @prj_data = [false,nil]
      mog_prj_initialize
  end
  
end

#==============================================================================
# ■ Cache
#==============================================================================
module Cache
  
  #--------------------------------------------------------------------------
  # ● Projectile
  #--------------------------------------------------------------------------
  def self.projectile(filename)
      load_bitmap("Graphics/Projectile/", filename)    
  end
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Projectile
  #--------------------------------------------------------------------------
  alias mog_projectile_show_normal_animation show_normal_animation
  def show_normal_animation(targets, animation_id, mirror = false)
      item = @subject.current_action.item rescue nil
      execute_projectile_effect(targets,item) if execute_projectile_effect?(item)
      mog_projectile_show_normal_animation(targets, animation_id, mirror)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Projectile Effect
  #--------------------------------------------------------------------------
  def execute_projectile_effect?(item)
      return false if item.nil?
      return false if !@projectile_effect.nil?
      if skill_weapon?(item) and !@subject.equips[0].nil?
          return true if @subject.equips[0].note =~ /<Projectile = (\d+)>/
          return true if @subject.equips[0].note =~ /<Projectile R = (\d+)>/
          return true if @subject.equips[0].note =~ /<Projectile>/
          return true if @subject.equips[0].note =~ /<Projectile R>/
          return true if @subject.equips[0].note =~ /<Projectile S = (\S+)>/
      end
      return true if item.note =~ /<Projectile = (\d+)>/
      return true if item.note =~ /<Projectile R = (\d+)>/
      return true if item.note =~ /<Projectile>/
      return true if item.note =~ /<Projectile R>/
      return true if item.note =~ /<Projectile S = (\S+)>/
      return false
  end

  #--------------------------------------------------------------------------
  # ● Skill Weapon
  #--------------------------------------------------------------------------
  def skill_weapon?(item)
      return false if !item.is_a?(RPG::Skill)
      return false if !@subject.is_a?(Game_Actor)
      return false if item.id != @subject.attack_skill_id 
      return true
  end    
      
  #--------------------------------------------------------------------------
  # ● Execute Projectile Effect
  #--------------------------------------------------------------------------
  def execute_projectile_effect(targets,item)
      @projectile_effect = true
      @prj = [[],[]] ; @rvp = false
      animation = set_projectile_animation(item)
      sprite_name_p = set_p_sprite_name(item)
      set_projectile_initial_position(targets,item,animation,sprite_name_p)
      return if @prj[0].empty? or @prj[1].empty?
      update_phase_projectile
      @projectile.each do |prjt| prjt.dispose end
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Phase Projectile
  #--------------------------------------------------------------------------
  def update_phase_projectile
      loop do
          motion_done = true
          @projectile.each do |prjt|
          prjt.update ; motion_done = false if !prjt.motion_done
          end
          update_basic
          break if motion_done
      end  
  end
    
  #--------------------------------------------------------------------------
  # ● Set Projectile Initial Position
  #--------------------------------------------------------------------------
  def set_projectile_initial_position(targets,item,animation,sprite_name_p)
      $game_temp.prj_data = [false,nil] ; @prim_target = nil      
      if $imported[:mog_scope_ex] and item.note =~ /<Unique Animation>/
         @prim_target = @subject.primary_target if !@subject.primary_target.nil?
      end
      for battler in @spriteset.battler_sprites
          next if battler.bitmap.nil?
          viewport = battler.viewport ; z_axis = battler.z + 1
          @prj[0] = [battler.x,battler.y - battler.bitmap.height / 2,battler] if @subject == battler.battler
          next if !targets.include?(battler.battler)
          next if !@prim_target.nil? and battler.battler != @prim_target
          @prj[1].push([battler.battler,[battler.x,battler.y - battler.bitmap.height / 2],battler])
      end     
      @projectile = []
      @prj[1].each do |battler| 
      @projectile.push(Sprite_Projectile.new(viewport,battler,@prj[0],z_axis,animation,@rvp,item,@subject,sprite_name_p))
      end
  end
      
  #--------------------------------------------------------------------------
  # ● Set P Sprite Name 
  #--------------------------------------------------------------------------
  def set_p_sprite_name(item)
      if item.note =~ /<Projectile S = (\S+)>/
         return $1.to_s
      elsif skill_weapon?(item) and !@subject.equips[0].nil?
         return $1.to_s if @subject.equips[0].note =~ /<Projectile S = (\S+)>/
      end  
      return nil
  end
  
  #--------------------------------------------------------------------------
  # ● Set Projectile Animation
  #--------------------------------------------------------------------------
  def set_projectile_animation(item)
      if item.note =~ /<Projectile>/ ; return nil
      elsif item.note =~ /<Projectile R>/ ; @rvp = true ; return nil
      elsif skill_weapon?(item) and !@subject.equips[0].nil?
         ani_id = $1.to_i if @subject.equips[0].note =~ /<Projectile = (\d+)>/
         if @subject.equips[0].note =~ /<Projectile R = (\d+)>/
            ani_id = $1.to_i ; @rvp = true
         elsif @subject.equips[0].note =~ /<Projectile R>/
            ani_id = nil ; @rvp = true
         end
         return $data_animations[ani_id] rescue nil
      else  
         ani_id = $1.to_i if item.note =~ /<Projectile = (\d+)>/
         if item.note =~ /<Projectile R = (\d+)>/
            ani_id = $1.to_i ; @rvp = true
         end   
         return $data_animations[ani_id] rescue nil
      end  
      return nil
  end    
      
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------
  alias mog_projectile_use_item use_item
  def use_item
      mog_projectile_use_item
      @projectile_effect = nil
  end
   
end

#==============================================================================
# ■  Battle
#==============================================================================
class Sprite_Projectile < Sprite_Base
  attr_accessor :motion_done
  
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize(viewport, battler_data, dest,z_axis,animation,rv,item,user,sprite_name)
      super(viewport)
      if !rv
         @battler_cp = [dest[0],dest[1]] ; @battler = battler_data[0]
         @battler_np = [battler_data[1][0],battler_data[1][1]]
         @user_sprite = dest[2]
      else   
         @battler_cp = [battler_data[1][0],battler_data[1][1]]
         @battler_np = [dest[0],dest[1]] ; @battler = battler_data[0]
         @user_sprite = battler_data[2]
      end  
      set_sprite_name(user,sprite_name,animation,item)
      self.ox = self.bitmap.width / 2 ; self.oy = self.bitmap.width / 2
      self.x = @battler_cp[0] ; self.y = @battler_cp[1] ; self.z = z_axis + 1
      set_sprite_angle(user) if $imported[:mog_sprite_actor]
      start_animation(animation, false) unless animation.nil?
      x_plus = (self.x - @battler_cp[0]).abs ; y_plus = (self.y - @battler_cp[1]).abs
      distance = Math.sqrt(x_plus + y_plus).round + 10 
      @p_peak = (distance * 80 / 100).truncate
      @p_count = [0,@p_peak * 2] 
      @motion_done = false ; @end_phase = [false,0] 
      @target = true if !$game_temp.prj_data[0] ; @s_visible = true
      $game_temp.prj_data[0] = false
  end
  
  #--------------------------------------------------------------------------
  # ● Set Sprite Angle
  #--------------------------------------------------------------------------
  def set_sprite_angle(user)
      return if user.is_a?(Game_Enemy)
      case user.bact_sprite[0]
         when 2 ; self.angle = 90
         when 4 ; self.angle = 0
         when 6 ; self.mirror = true
         when 8 ; self.angle = 270
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Set Sprite Name
  #--------------------------------------------------------------------------
  def set_sprite_name(user,sprite_name,animation,item)
      if !sprite_name.nil?
         self.bitmap = Cache.projectile(sprite_name.to_s)
      else
         self.bitmap = Bitmap.new(24,24)
         if animation.nil? ; image = Cache.system("Iconset")
            if user.is_a?(Game_Actor) and item.is_a?(RPG::Skill) and
               item.id == user.attack_skill_id and !user.equips[0].nil?
               rect = Rect.new(user.equips[0].icon_index % 16 * 24, user.equips[0].icon_index / 16 * 24, 24, 24)
            else   
               rect = Rect.new(item.icon_index % 16 * 24, item.icon_index / 16 * 24, 24, 24)
            end
            self.bitmap.blt(0, 0, image, rect)
          else  
              if animation.position == 0
                 @battler_cp[1] -= (@user_sprite.bitmap.height / 2) 
              elsif animation.position == 2
                 @battler_cp[1] += (@user_sprite.bitmap.height / 2)
              end
         end
       end
  end     
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------
  def dispose
      bitmap.dispose if bitmap
      $game_temp.prj_data = [false,nil]
      super
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  def update
      super
      self.viewport.update
      update_p([@battler_np[0],@battler_np[1]])
      if self.x == @battler_np[0] and self.y == @battler_np[1] and !@end_phase[0]
         @end_phase = [true,5]
      end  
      if @end_phase[0] and @end_phase[1] > 0
         @end_phase[1] -= 1
         @motion_done = true if @end_phase[1] == 0     
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Update p
  #--------------------------------------------------------------------------      
  def update_p(np)
      @p_count[0] += 1
      return if @p_count[0] < 2
      @p_count[0] = 0 ; @p_count[1] -= 1 if @p_count[1] > 0
      self.x = (self.x * @p_count[1] + np[0]) / (@p_count[1] + 1.0)
      self.y = ((self.y * @p_count[1] + np[1]) / (@p_count[1] + 1.0)) - p_height
      $game_temp.prj_data[1] = self if @target
  end
  
  #--------------------------------------------------------------------------
  # ● P Height
  #--------------------------------------------------------------------------      
  def p_height
      return (@p_peak * @p_peak - (@p_count[1] - @p_peak).abs ** 2) / 40
  end  

  #--------------------------------------------------------------------------
  # ● Animation Set Sprite
  #--------------------------------------------------------------------------      
  def animation_set_sprites(frame)    
      @ani_ox = self.x ; @ani_oy = self.y
      super
      @ani_sprites.each_with_index do |sprite, i| sprite.z = self.z + 1  end
  end  
  
end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  attr_accessor :skill_fade_bb
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_skill_bb_fade_initialize initialize
  def initialize
      @skill_fade_bb = false
      mog_skill_bb_fade_initialize
  end
  
end
#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● Fade Background
  #--------------------------------------------------------------------------  
  def fade_background(value)
      return if BattleManager.subject_user.nil?
      $game_temp.skill_fade_bb = value
  end    
  
  #--------------------------------------------------------------------------
  # ● Hide Allies
  #--------------------------------------------------------------------------  
  def hide_allies(value)
      return if BattleManager.subject_user.nil?
      if BattleManager.subject_user.is_a?(Game_Actor) 
         $game_party.battle_members.each do |battler| battler.fade = value end
      else  
         $game_troop.alive_members.each do |battler|
         next if battler.dead? ; battler.fade = value end
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Hide Enemies
  #--------------------------------------------------------------------------  
  def hide_enemies(value)
      return if BattleManager.subject_user.nil?
      if BattleManager.subject_user.is_a?(Game_Actor) 
         $game_troop.alive_members.each do |battler| battler.fade = value end
      else  
         $game_party.battle_members.each do |battler| battler.fade = value end
      end
  end

  #--------------------------------------------------------------------------
  # ● Hide User
  #--------------------------------------------------------------------------  
  def hide_user(value)
      return if BattleManager.subject_user.nil?
      BattleManager.subject_user.fade = value
  end
  
end

#==============================================================================
# ■ Game Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  attr_accessor :fade
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_initialize initialize
  def initialize
      @fade = false
      mog_skill_ex_initialize
  end
  
end

#==============================================================================
# ■ BattleManager
#==============================================================================
class << BattleManager
   
  #--------------------------------------------------------------------------
  # ● Process Defeat
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_process_defeat process_defeat
  def process_defeat
      $game_temp.skill_fade_bb = false
      $game_party.battle_members.each do |battler| battler.fade = false end
      $game_troop.alive_members.each do |battler|
      next if battler.dead? ; battler.fade = false end         
      mog_skill_ex_process_defeat
  end  
    
  #--------------------------------------------------------------------------
  # ● Process Victory
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_process_victory process_victory
  def process_victory
      $game_temp.skill_fade_bb = false
      $game_party.battle_members.each do |battler| battler.fade = false end
      $game_troop.alive_members.each do |battler|
      next if battler.dead? ; battler.fade = false end     
      mog_skill_ex_process_victory
  end
  
end

#===============================================================================
# ■ Sprite Base
#===============================================================================
class Sprite_Base < Sprite
  
  #--------------------------------------------------------------------------
  # ● Animation set Sprites
  #--------------------------------------------------------------------------
  alias mog_sprite_actor_animation_set_sprites animation_set_sprites
  def animation_set_sprites(frame)
      mog_sprite_actor_animation_set_sprites(frame)
      update_force_sprite_opacity(frame) rescue nil
  end  

  #--------------------------------------------------------------------------
  # ● Update Force Sprite Opacity
  #--------------------------------------------------------------------------
  def update_force_sprite_opacity(frame)
      cell_data = frame.cell_data
      if !@battler.nil? and @battler.dead?        
         @ani_sprites.each_with_index do |sprite, i|
         next if sprite.nil? or cell_data[i, 6].nil?
         sprite.opacity = cell_data[i, 6]
      end  
      end    
  end
      
end

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base

  #--------------------------------------------------------------------------
  # ● Update Effect
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_update_effect update_effect
  def update_effect
      mog_skill_ex_update_effect
      update_fade_effect if update_fade_effect?
  end
  
  #--------------------------------------------------------------------------
  # ● Revert To Normal
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_revert_to_normal revert_to_normal
  def revert_to_normal
      return if @battler.fade and !@battler.dead?
      mog_skill_ex_revert_to_normal
  end
  
  #--------------------------------------------------------------------------
  # ● Update Fade Effect
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_update_blink update_blink
  def update_blink
      return if @battler.fade
      mog_skill_ex_update_blink
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Fade Effect
  #--------------------------------------------------------------------------  
  def update_fade_effect?
      return false if @effect_duration > 0
      return false if !@battler.exist?
      return false if @battler.dead?
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Update Fade Effect
  #--------------------------------------------------------------------------  
  def update_fade_effect
      opc = @battler.fade ? -15 : 15 ; self.opacity += opc
  end
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Start
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_start start
  def start
      mog_skill_ex_start
      clear_skill_ex_effects
  end
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------  
  alias mog_skill_bb_fade use_item
  def use_item
      item = @subject.current_action.item rescue nil
      $game_temp.skill_fade_bb = true if !item.nil? and item.note =~ /<Fade Background>/
      mog_skill_bb_fade
      clear_skill_ex_effects
  end

  #--------------------------------------------------------------------------
  # ● Clear Skill EX Effects
  #--------------------------------------------------------------------------  
  def clear_skill_ex_effects
      $game_temp.skill_fade_bb = false
      $game_party.battle_members.each do |battler| battler.fade = false end
      $game_troop.alive_members.each do |battler|
      next if battler.dead? ; battler.fade = false end       
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Skill EX Effects
  #--------------------------------------------------------------------------  
  alias mog_skill_ex_effects_show_animation show_animation
  def show_animation(targets, animation_id)
      item = @subject.current_action.item rescue nil
      execute_skill_ex_animation(item,targets) if !item.nil?
      mog_skill_ex_effects_show_animation(targets, animation_id)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Skill EX Animation
  #--------------------------------------------------------------------------  
  def execute_skill_ex_animation(item,targets)
      if item.note =~ /<Play Movie = (\S+)>/
         Graphics.fadeout(60)
         Graphics.play_movie('Movies/' + $1.to_s)
         Graphics.fadein(15) 
      end  
      if item.note =~ /<Hide Enemies>/
         if @subject.is_a?(Game_Actor) 
            $game_troop.alive_members.each do |battler| battler.fade = true end
         else  
            $game_party.battle_members.each do |battler| battler.fade = true end
         end
      end
      if item.note =~ /<Hide Allies>/
         if @subject.is_a?(Game_Actor) 
            $game_party.battle_members.each do |battler| battler.fade = true end
         else  
            $game_troop.alive_members.each do |battler|
            next if battler.dead? ; battler.fade = true end
         end
      end      
      @subject.fade = true if item.note =~ /<Hide User A>/
  end  
  
  #--------------------------------------------------------------------------
  # ● Process Bact End
  #--------------------------------------------------------------------------  
  if $imported[:mog_battler_motion]
  alias mog_skill_ex_process_bact_end process_bact_end
  def process_bact_end
      clear_skill_ex_effects
      mog_skill_ex_process_bact_end
  end  
  end

end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  alias mog_bb_skill_update update
  def update
      update_skill_bb_fade
      mog_bb_skill_update
  end
    
  #--------------------------------------------------------------------------
  # ● Update Skill BB Fade
  #--------------------------------------------------------------------------  
  def update_skill_bb_fade
      opa = $game_temp.skill_fade_bb ? -15 : 15
      @back1_sprite.opacity += opa if !@back1_sprite.nil?
      @back2_sprite.opacity += opa if !@back2_sprite.nil?
  end
  
end