#==============================================================================
# +++ MOG - Battler Motion (v3.6) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Adiciona efeitos de animações nos sprites dos battlers.
# ● Animação inicial (entrada)de batalha.
# ● Animação de espera.
# ● Animação de ação.
# ● Animação de dano.
# ● Animação de colapso.
#==============================================================================

#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v3.6 - Melhoria na compatibilidade com MOG Battle Camera.
# v3.5 - Possibilidade de desabilitar o efeito "blinking"
#      - Melhoria no tempo de execução do efeito slice
# v3.4 - Adição da função SLICE.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_battler_motion] = true

#==============================================================================
# ● CONFIGURAÇÃO
#==============================================================================
# ■ Animação inicial de entrada ao começar a batalha. 
#==============================================================================
# Coloque as seguintes Tags na caixa de notas dos inimigos ou personagens.
#
# <Motion Appear = X>
#
# X = 0
# Battler desliza horizontalmente.
#
# X = 1
# Battler desliza verticalmente.
#
# X = 2
# Battler rola (Cambalhota O_o) pela tela.
#
# X = 3
# Zoom IN
#
# X = 4
# Zoom Out
#
# X = 5
# Efeito de emergir do solo. 
#
#==============================================================================
# ■ Animações dos battlers em modo espera. 
#==============================================================================
# Coloque as seguintes Tags na caixa de notas dos inimigos ou personagens.
#
# <Motion Standby = X>
#
# X = 0
# Ativa o efeito do battler respirando.
#
# X = 1
# Ativa o efeito do battler levitando.
#
# X = 2
# Ativa o efeito do battler movimentando para os lados.
#
#==============================================================================
# ■ Animações dos battlers em modo de ação. 
#==============================================================================
# Coloque as seguintes Tags na caixa de notas de itens ou habilidades.
#
# <Motion Action = X>
# 
# X = 0
# Ativa o efeito de ação de zoom.
#
# X = 1
# Ativa o efeito de ação de pular.
#
# X = 2
# Ativa o efeito de girar para a esquerda.
#
# X = 3
# Ativa o efeito de girar para a direita.
#
# X = 4
# Ativa o efeito de tremer.
#
# X = 5
# Ativa o efeito de ação frontal.
#
# X = 6
# Ativa o efeito de dar um passo para esquerda.
#
# X = 7
# Ativa o efeito de de dar um passo para direita.
#
#==============================================================================
# ■ Animações dos battlers em Colapso. 
#==============================================================================
# Coloque as seguintes Tags na caixa de notas dos inimigos ou personagens.
#
# <Motion Collapse = X>
#
# X = 0
# Ativa colapso na vertical.
#
# X = 1 
# Ativa o colapso na horizontal.
#
# X = 2
# Ativa o colapso em Zoom OUT.
#
# X = 3
# Ativa o colapso em Zoom IN.
#
# X = 4
# Ativa o colapso em Zoom IN e Zoom OUT.
#
# X = 5
# Ativa o colapso em Modo Boss.
#
# X = 6
# Não ativa colapso.(Do nothing)
#
# X = 7
# Ativa o collapse em Slice.
#
#==============================================================================
# ■ Forçar o collapso Slice
#==============================================================================
# Coloque a Tag abaixo na caixa de notas da habilidade.
#
# <Slice>
#
#==============================================================================
# ■ Ativar animação de dano em condições maléficas.
#==============================================================================
# Coloque a seguinte Tag na caixa de notas de condições para ativar o efeito
# de dano.
#
# <Bad State>
#
#==============================================================================
# ■ Definir uma posição específica do battler inimigo
#==============================================================================
# Para definir uma posição do inimigo na tela use a Tag abaixo na caixa
# dos inimigos
#
# <Screen X Y = 150 - 400> 
#
#==============================================================================
module MOG_BATTLER_MOTION

  #============================================================================
  #Ativar o efeito no aliados.
  #============================================================================
  ENABLE_ACTOR_MOTION = true
  
  #============================================================================
  #Ativar o efeito nos inimigos
  #============================================================================
  ENABLE_ENEMY_MOTION = true
  
  #============================================================================
  #Definição da velocidade do efeito de respirar.
  #============================================================================
  BREATH_EFFECT_SPEED = 1  #Default 1
  
  #============================================================================
  #Definição do limite de zoom do efeito de respirar.
  #============================================================================
  BREATH_EFFECT_RANGE = [0.92, 1.00] #Default [0.92, 1.00]
  
  #============================================================================
  # Ativar a função mirror dependendo do lado do oponente.
  #============================================================================
  BATTLER_MIRROR_DIRECTION = true
  
  #============================================================================
  # Ativar o efeito Blink ao receber dano.
  #============================================================================
  ENABLE_DAMAGE_BLINK_EFFECT = false
end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  
  attr_accessor :battler_in_motion
  attr_accessor :bact_wait_d
  attr_accessor :bact_phase
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------       
  alias mog_battler_motion_initialize initialize
  def initialize
      @battler_in_motion = false ; @bact_wait_d = 0 ; @bact_phase = [0,0]
      mog_battler_motion_initialize
  end  
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
   attr_accessor :motion_start
   attr_accessor :motion_stand
   attr_accessor :motion_action
   attr_accessor :motion_damage
   attr_accessor :motion_collapse
   attr_accessor :motion_slice
   attr_accessor :motion_move
   attr_accessor :motion_org_pos
   attr_accessor :motion_bms
   attr_accessor :bact_action
   attr_accessor :bact_skill
   attr_accessor :primary_target
   
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------       
   alias mog_motion_animation_initialize initialize
   def initialize
       mog_motion_animation_initialize
       @motion_start = -1
       @motion_stand = [-1,0]
       @motion_action = [-1,0]
       @motion_collapse = [99,0]
       @motion_damage = [0,0]
       @motion_move = [false,0,0]
       @motion_org_pos = [0,0]
       @motion_bms = [0,false]
       @motion_slice = [false,0,0]
       bact_action_clear
   end     

  #--------------------------------------------------------------------------
  # ● Bact Action Clear
  #--------------------------------------------------------------------------      
  def bact_action_clear
      @bact_action = [false,0,0] ; @bact_skill = nil
  end   

  #--------------------------------------------------------------------------
  # ● Added New State
  #--------------------------------------------------------------------------  
  alias mog_motion_animation_add_new_state add_new_state
  def add_new_state(state_id)
      mog_motion_animation_add_new_state(state_id)
      self.motion_damage[0] = 1 if $data_states[state_id].note =~ /<Bad State>/
  end   
 
  #--------------------------------------------------------------------------
  # ● Move To
  #--------------------------------------------------------------------------  
  def move_to(x,y)
      return if self.dead?
      @motion_move = [true,x,y]
  end
  
  #--------------------------------------------------------------------------
  # ● Set Original Position
  #--------------------------------------------------------------------------  
  def set_org_pos
      scx = self.screen_x rescue 0
      scy = self.screen_y rescue 0    
      @motion_opos = [scx,scy]
  end
  
  #--------------------------------------------------------------------------
  # ● Return Org
  #--------------------------------------------------------------------------  
  def return_org
      return if self.dead?
      @motion_move = [true,@motion_opos[0],@motion_opos[1]]    
  end
    
  #--------------------------------------------------------------------------
  # ● Item Apply
  #--------------------------------------------------------------------------  
  alias mog_bactmotion_item_apply item_apply
  def item_apply(user, item)
      return if self.motion_slice[0]
      mog_bactmotion_item_apply(user, item)
      unless self.is_a?(Game_Actor)
         self.motion_collapse[0] = 7 if self.dead? and item.note =~ /<Slice>/
      end
  end
  
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
   
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_motion_animation_enemy_initialize initialize
  def initialize(index, enemy_id)
      mog_motion_animation_enemy_initialize(index, enemy_id)
      setup_motion_animation(enemy_id)
  end
  
  #--------------------------------------------------------------------------
  # ● Setup Motion Animation
  #--------------------------------------------------------------------------  
  def setup_motion_animation(enemy_id)
      self.motion_stand[0] = $1.to_i if  enemy.note =~ /<Motion Standby = (\d+)>/i 
      self.motion_collapse[0] = $1.to_i if  enemy.note =~ /<Motion Collapse = (\d+)>/i 
      self.motion_start =  $1.to_i if  enemy.note =~ /<Motion Appear = (\d+)>/i 
  end
end

#==============================================================================
# ■ Game Actor
#==============================================================================
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------
  # ● Setup
  #--------------------------------------------------------------------------
  alias mog_motion_animation_actor_setup setup
  def setup(actor_id)
      mog_motion_animation_actor_setup(actor_id)
      self.motion_stand[0] = $1.to_i if  actor.note =~ /<Motion Standby = (\d+)>/i
      self.motion_collapse[0] = $1.to_i if  actor.note =~ /<Motion Collapse = (\d+)>/i       
      self.motion_start =  $1.to_i if  actor.note =~ /<Motion Appear = (\d+)>/i  
  end

end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # ● Execute Damage
  #--------------------------------------------------------------------------  
  alias mog_battler_motion_execute_damage execute_damage
  def execute_damage(user)
      mog_battler_motion_execute_damage(user)
      self.motion_damage[0] = 1 if @result.hp_damage > 0
  end
  
end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  alias mog_battler_motion_update update
  def update
      $game_temp.battler_in_motion = false
      mog_battler_motion_update
  end
  
  #--------------------------------------------------------------------------
  # * Animation?
  #--------------------------------------------------------------------------
  alias mog_battler_motion_animation? animation?
  def animation?
      return true if $game_temp.battler_in_motion
      mog_battler_motion_animation?
  end
  #--------------------------------------------------------------------------
  # * Effect?
  #--------------------------------------------------------------------------
  alias mog_battler_motion_effect? effect?
  def effect?
      return true if $game_temp.battler_in_motion
      mog_battler_motion_effect?
  end
  
end


#==============================================================================
#==============================================================================
# ● INITIAL ●
#==============================================================================
#==============================================================================

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base

  #--------------------------------------------------------------------------
  # ● Update Bitmap
  #--------------------------------------------------------------------------    
  alias mog_bactmotion_update_bitmap update_bitmap
  def update_bitmap
      return if @battler.motion_slice[0]
      mog_bactmotion_update_bitmap
  end    
      
  #--------------------------------------------------------------------------
  # ● Can Update Motion?
  #--------------------------------------------------------------------------    
  def can_update_motion?
      return true
  end   
  
  #--------------------------------------------------------------------------
  # ● Update Position
  #--------------------------------------------------------------------------  
  alias mog_motion_animation_update_position update_position
  def update_position
      active_battler_motion      
      if @battler_motion_active
         update_motion_animation
         self.z = @battler.screen_z rescue nil
         self.z += 20 if @battler.bact_data[1] != nil and !@battler.bact_data[6]
         return
      end      
      mog_motion_animation_update_position
      self.z += 20 if @battler.bact_data[1] != nil and !@battler.bact_data[6]
  end  
  
  #--------------------------------------------------------------------------
  # ● Active Battler Motion
  #--------------------------------------------------------------------------    
  def active_battler_motion
      return if @motion_initial_base != nil or bitmap == nil
      return if @battler == nil
      return if !@battler.exist?
      @motion_initial_base = true
      @battler_motion_active = true if can_update_battler_motion?
  end  
  
  #--------------------------------------------------------------------------
  # ● Can Update Battler Motion
  #--------------------------------------------------------------------------      
  def can_update_battler_motion?
      return false if @battler.is_a?(Game_Actor)
      return false if @battler == nil
      return false if @battler.dead?
      return false if !@battler.use_sprite?
      return false if @battler.screen_x == nil
      return false if @battler.is_a?(Game_Actor) and !MOG_BATTLER_MOTION::ENABLE_ACTOR_MOTION
      return false if @battler.is_a?(Game_Enemy) and !MOG_BATTLER_MOTION::ENABLE_ENEMY_MOTION
      return false if $imported[:mog_sprite_actor] and @battler.is_a?(Game_Actor)
      return true
  end
    
  #--------------------------------------------------------------------------
  # ● Update Motion Animation
  #--------------------------------------------------------------------------    
  def update_motion_animation
      setup_initial_motion
      execute_start_animation
      return if @wait_motion_start 
      if can_execute_collapse?
         execute_motion_collapse
      else
         if can_update_motion?
            execute_motion_move_to if can_update_move_to?
            execute_motion_damage 
            execute_motion_idle if can_update_idle?
            execute_motion_action if can_update_action?
         end
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Setup Initial Motion
  #--------------------------------------------------------------------------      
  def setup_initial_motion
      return if @motion_initial != nil
      @motion_initial = true
      @collapse_done = false
      @motion_speed = 0
      @start_speed = [0,0]      
      @battler.motion_collapse[1] = 0
      self.x = @battler.screen_x rescue 0
      self.y = @battler.screen_y rescue 0
      self.z = @battler.screen_z rescue 100
      @battler.motion_bms = [0,false]
      @battler.set_org_pos      
      setup_motion_stand
      @original_set = [self.x, self.y, self.zoom_x,self.zoom_y,self.mirror,self.angle,255] 
      setup_motion_start
      setup_motion_damage            
      setup_motion_action
  end  

  #--------------------------------------------------------------------------
  # ● Return Set
  #--------------------------------------------------------------------------          
  def return_set(value)
      self.x = value[0]
      self.y = value[1]
      self.zoom_x = value[2]
      self.zoom_y = value[3]
      self.mirror = value[4]
      self.angle = value[5]
      self.opacity = value[6]      
  end  
 
  #--------------------------------------------------------------------------
  # ● setup_motion_start
  #--------------------------------------------------------------------------            
  def setup_motion_start
      @wait_motion_start = true
      @scr_rect_speed = 1      
      case @battler.motion_start
         when 0  
            self.x = 0 - (self.bitmap.width + rand(100))
         when 1 
            self.y = 0 - (self.bitmap.height + rand(100))
         when 2   
            self.angle = 360
            self.x = 0 - self.bitmap.width
         when 3   
            self.zoom_x = 1.5 + (rand(10) / 100.0)
            self.zoom_y = self.zoom_x
            self.opacity = 0
         when 4
            self.zoom_x = 0.2 + (rand(10) / 100.0)
            self.zoom_y = self.zoom_x
            self.opacity = 0
         when 5   
            self.src_rect.y = -self.bitmap.height
            @scr_rect_speed = self.bitmap.height / 40
            @scr_rect_speed = 1 if @scr_rect_speed <= 0
         else   
           @wait_motion_start = false
      end   
  end  
  
  #--------------------------------------------------------------------------
  # ● Execute Start Animation
  #--------------------------------------------------------------------------          
  def execute_start_animation
      return if !@wait_motion_start
      $game_temp.battler_in_motion = true
      s_x = 1 + ((self.x - @original_set[0]).abs / (20 + @start_speed[0]))
      s_y = 1 + ((self.y - @original_set[1]).abs / (20 + @start_speed[1]))      
      if self.x < @original_set[0]
         self.x += s_x
         self.x = @original_set[0] if self.x >= @original_set[0]
      elsif self.x > @original_set[0]
         self.x -= s_x
         self.x = @original_set[0] if self.x <= @original_set[0]
      end
      if self.y < @original_set[1]
         self.y += s_y
         self.y = @original_set[1] if self.y > @original_set[1]
      elsif self.y > @original_set[1]
         self.y -= s_y
         self.y = @original_set[1] if self.y < @original_set[1]
      end
      if self.zoom_x != @original_set[2]
         if self.zoom_x > @original_set[2]
            self.zoom_x -= 0.01
            self.zoom_x = @original_set[2] if self.zoom_x < @original_set[2]
         elsif self.zoom_x < @original_set[2]
            self.zoom_x += 0.01
            self.zoom_x = @original_set[2] if self.zoom_x > @original_set[2]
         end          
      end  
      if self.zoom_y != @original_set[3]
         if self.zoom_y > @original_set[3]
            self.zoom_y -= 0.01
            self.zoom_y = @original_set[3] if self.zoom_y < @original_set[3]
         elsif self.zoom_y < @original_set[3]
            self.zoom_y += 0.01
            self.zoom_y = @original_set[3] if self.zoom_y > @original_set[3]
         end          
      end        
      self.opacity += 10
      if self.angle > 0
         self.angle -= 5 
         self.angle = @original_set[5] if self.angle < @original_set[5]
      end
      if self.src_rect.y != 0
         self.src_rect.y += @scr_rect_speed
         self.src_rect.y = 0 if self.src_rect.y > 0
      end
      if sprite_original_set?  
         @wait_motion_start = false
         @battler.motion_bms[1] = true
         self.src_rect.y = 0
      end   
  end  
  
  #--------------------------------------------------------------------------
  # ● Sprite original Set?
  #--------------------------------------------------------------------------          
  def sprite_original_set?
      return false if self.x != @original_set[0]
      return false if self.y != @original_set[1]   
      return false if self.zoom_x != @original_set[2]
      return false if self.zoom_y != @original_set[3]        
      return false if self.mirror != @original_set[4]
      return false if self.angle != @original_set[5]
      return false if self.opacity != @original_set[6]     
      return false if self.src_rect.y != 0      
      return true
  end  
    
end

#==============================================================================
#==============================================================================
# ● MOVE TO ●
#==============================================================================
#==============================================================================

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Can Update Move_to
  #--------------------------------------------------------------------------    
  def can_update_move_to?
      return false if !@battler.motion_move[0]
      return true
  end  
  
  #--------------------------------------------------------------------------
  # ● Execute Motion Move_to
  #--------------------------------------------------------------------------        
  def execute_motion_move_to      
      $game_temp.battler_in_motion = true
      execute_motion_mv(0,self.x,@battler.motion_move[1])
      execute_motion_mv(1,self.y,@battler.motion_move[2])
      mv_clear
  end
   
  #--------------------------------------------------------------------------
  # ● MV Clear
  #--------------------------------------------------------------------------      
  def mv_clear
      return if self.x != @battler.motion_move[1]
      return if self.y != @battler.motion_move[2]
      @battler.motion_move[0] = false
  end
      
  #--------------------------------------------------------------------------
  # ● Execute Motion Mv
  #--------------------------------------------------------------------------      
  def execute_motion_mv(type,cp,np)
      sp = 2 + ((cp - np).abs / 20)
      if cp > np 
         cp -= sp
         cp = np if cp < np
      elsif cp < np 
         cp += sp
         cp = np if cp > np
      end     
      self.x = cp if type == 0
      self.y = cp if type == 1
  end    
  
end

#==============================================================================
#==============================================================================
# ● DAMAGE ●
#==============================================================================
#==============================================================================

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base

  #--------------------------------------------------------------------------
  # ● Can Update Damage
  #--------------------------------------------------------------------------    
  def can_update_damage?
      return false if @battler.motion_damage[1] == 0
      return false if @battler.motion_move[0]
      return false if $imported[:mog_battle_camera] and $game_temp.bc_wait_cp[0] > 0
      return true
  end    
  
  #--------------------------------------------------------------------------
  # ● Setup Initial Motion
  #--------------------------------------------------------------------------        
  def execute_motion_damage
      damage_refresh
      update_motion_damage if can_update_damage?
  end

  #--------------------------------------------------------------------------
  # ● Setup Motion Damage
  #--------------------------------------------------------------------------        
  def setup_motion_damage     
      @battler.motion_damage = [0,0]
      @damage_pre_set = [self.x, self.y, self.zoom_x,self.zoom_y,self.mirror,self.angle,self.opacity]
  end  
  
  #--------------------------------------------------------------------------
  # ● Damage Refresh
  #--------------------------------------------------------------------------          
  def damage_refresh
      return if @battler.motion_damage[0] == 0
      if @battler.motion_damage[1] == 0
         @damage_pre_set = [self.x, self.y, self.zoom_x,self.zoom_y,self.mirror,self.angle,self.opacity]
      end
      @battler.motion_damage[0] = 0 
      @battler.motion_damage[1] = 45
  end
  
  #--------------------------------------------------------------------------
  # ● Update Motion Damage
  #--------------------------------------------------------------------------            
  def update_motion_damage
      return if @damage_pre_set.nil?
      self.x = @damage_pre_set[0] + rand(@battler.motion_damage[1])
      @battler.motion_damage[1] -= 1
      if @battler.motion_damage[1] == 0 
         if $imported[:mog_battle_hud_ex] != nil and @battler.is_a?(Game_Actor)
            return_set(@original_set) 
         else  
            return_set(@damage_pre_set)
         end   
      end  
  end
    
end

#==============================================================================
#==============================================================================
# ● IDLE ●
#==============================================================================
#==============================================================================


#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Can Update idle
  #--------------------------------------------------------------------------    
  def can_update_idle?
      return false if @old_motion_action != -1
      return false if @battler.motion_damage[1] > 0
      return false if @battler.motion_move[0]
      return false if $imported[:mog_battle_camera] and $game_temp.bc_wait_cp[0] > 0
      return true
  end      

  #--------------------------------------------------------------------------
  # ● Setup Motion Stand
  #--------------------------------------------------------------------------        
  def setup_motion_stand
      @breath_range = [MOG_BATTLER_MOTION::BREATH_EFFECT_RANGE[0],
                       MOG_BATTLER_MOTION::BREATH_EFFECT_RANGE[1],0,
                       MOG_BATTLER_MOTION::BREATH_EFFECT_SPEED]
      @float_range = [@battler.screen_y - 10, @battler.screen_y + 10]
      @side_range = [@battler.screen_x - 10, @battler.screen_x + 10]
      @battler.motion_stand[1] = 0
      case @battler.motion_stand[0]
         when 0
             self.zoom_y = @breath_range[0] + (rand(10) / 100.0)
             @battler.motion_stand[1] = rand(2) 
         when 1
             self.y += 10 - rand(20)
             @battler.motion_stand[1] = rand(2)
         when 2
             self.x += 10 - rand(20)
             @battler.motion_stand[1] = rand(2)             
      end
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Motion Animation
  #--------------------------------------------------------------------------        
  def execute_motion_idle
      case @battler.motion_stand[0]
         when 0
             update_motion_breath
         when 1  
             update_motion_float
         when 2
             update_motion_side
      end        
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Motion Breath
  #--------------------------------------------------------------------------          
  def update_motion_breath  
      @breath_range[2] += 1
      return if @breath_range[2] < @breath_range[3] 
      @breath_range[2] = 0
      case @battler.motion_stand[1]
         when 0
           self.zoom_y -= 0.002
           if self.zoom_y <= @breath_range[0]
              @battler.motion_stand[1] = 1
              self.zoom_y = @breath_range[0]
           end   
         when 1  
           self.zoom_y += 0.002
           if self.zoom_y >= @breath_range[1]
              @battler.motion_stand[1] = 0
              self.zoom_y = @breath_range[1]
           end   
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Motion Float
  #--------------------------------------------------------------------------          
  def update_motion_float
      @motion_speed += 1
      return if @motion_speed < 5
      @motion_speed = 0
      case @battler.motion_stand[1]
           when 0
                self.y -= 1
                @battler.motion_bms[0] -= 1
                if self.y < @float_range[0]
                   self.y = @float_range[0]
                   @battler.motion_bms[0] += 1
                   @battler.motion_stand[1] = 1
                end   
           when 1  
                self.y += 1
                @battler.motion_bms[0] += 1
                if self.y > @float_range[1]
                   self.y = @float_range[1]
                   @battler.motion_bms[0] -= 1
                   @battler.motion_stand[1] = 0
                end                  
      end
  end    
  
  #--------------------------------------------------------------------------
  # ● Update Motion Side
  #--------------------------------------------------------------------------          
  def update_motion_side
      @motion_speed += 1
      return if @motion_speed < 5
      @motion_speed = 0
      case @battler.motion_stand[1]
           when 0
                self.x -= 1
                if self.x < @side_range[0]
                   self.x = @side_range[0]
                   @battler.motion_stand[1] = 1
                end   
           when 1  
                self.x += 1
                if self.x > @side_range[1]
                   self.x = @side_range[1]
                   @battler.motion_stand[1] = 0
                end                  
      end
  end     
  
end

#==============================================================================
#==============================================================================
# ● ACTION ●
#==============================================================================
#==============================================================================

#==============================================================================
# ■ Game Action
#==============================================================================
class Game_Action
  
  #--------------------------------------------------------------------------
  # ● Prepare
  #--------------------------------------------------------------------------                  
  alias mog_motion_action_prepare prepare
  def prepare
      mog_motion_action_prepare   
      set_motion_action
  end
    
  #--------------------------------------------------------------------------
  # ● Set Motion Action
  #--------------------------------------------------------------------------                    
  def set_motion_action
      return if @item.object == nil or subject == nil
      subject.motion_action[0] = $1.to_i if @item.object.note =~ /<Motion Action = (\d+)>/i 
  end
  
end

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Can Update Action
  #--------------------------------------------------------------------------    
  def can_update_action?
      return false if @battler.motion_damage[1] > 0
      return false if @battler.motion_move[0]
      return false if $imported[:mog_battle_camera] and $game_temp.bc_wait_cp[0] > 0
      return true
  end       
  
  #--------------------------------------------------------------------------
  # ● Setup Motion Action
  #--------------------------------------------------------------------------        
  def setup_motion_action
      @battler.motion_action = [-1,0]
      @old_motion_action = @battler.motion_action[0]
      @pre_set = [self.x, self.y, self.zoom_x,self.zoom_y,self.mirror,self.angle,self.opacity]
  end

  #--------------------------------------------------------------------------
  # ● Refresh Action
  #--------------------------------------------------------------------------          
  def refresh_action
      return if @old_motion_action == @battler.motion_action[0]
      if @old_motion_action == -1
         @pre_set = [self.x, self.y, self.zoom_x,self.zoom_y,self.mirror,self.angle,self.opacity]
      end
      @battler.motion_action[1] = 0  
      return_set(@pre_set) 
      @old_motion_action = @battler.motion_action[0]
      self.src_rect.y =  0
  end  
  
  #--------------------------------------------------------------------------
  # ● Execute Motion Action
  #--------------------------------------------------------------------------            
  def execute_motion_action
      refresh_action
      update_motion_action
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Motion Action
  #--------------------------------------------------------------------------              
  def update_motion_action
      return if @battler.motion_action[0] == -1
      $game_temp.battler_in_motion = true
      @battler.motion_action[1] += 1
      case @battler.motion_action[0]
           when -2
              end_action
           when 0
              update_motion_zoom
           when 1
              update_motion_jump
           when 2  
              update_motion_round_right
           when 3
              update_motion_round_left
           when 4
              update_motion_shake
           when 5
              update_motion_front
           when 6   
              update_motion_step_left
           when 7
              update_motion_step_right              
      end 
  end
  
  #--------------------------------------------------------------------------
  # ● Update Motion Step Left
  #--------------------------------------------------------------------------                  
  def update_motion_step_left
      case @battler.motion_action[1] 
           when 1..20
                self.x -= 2
           when 21..40  
                self.x += 2           
           else
           end_action
      end    
    
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Motion Step Right
  #--------------------------------------------------------------------------                  
  def update_motion_step_right
      case @battler.motion_action[1] 
           when 1..20
                self.x += 2
           when 21..40  
                self.x -= 2           
           else
        end_action   
      end   
  end    
  
  #--------------------------------------------------------------------------
  # ● Update Motion Shake
  #--------------------------------------------------------------------------                
  def update_motion_shake      
      self.x = @pre_set[0] + rand(@battler.motion_action[1]) if can_update_motion_shake?
      end_action if @battler.motion_action[1] > 40
  end    
  
  #--------------------------------------------------------------------------
  # ● Can Update Motion Shake?
  #--------------------------------------------------------------------------                  
  def can_update_motion_shake?
      if $imported[:mog_battle_hud_ex] !=nil
         return false if @battler.is_a?(Game_Actor)
      end
      return true  
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Motion Zoom
  #--------------------------------------------------------------------------                
  def update_motion_zoom
      case @battler.motion_action[1]
        when 1..20
           self.zoom_x += 0.01
           self.zoom_y += 0.01
        when 21..40
           self.zoom_x -= 0.01
           self.zoom_y -= 0.01          
        else  
        end_action   
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Update Motion Jump
  #--------------------------------------------------------------------------                  
  def update_motion_jump
      case @battler.motion_action[1]
        when 1..20
            self.y -= 9
            self.zoom_x += 0.01
            self.zoom_y += 0.01
            self.mirror = true
            self.angle += 9
        when 21..40
            self.y += 9
            self.zoom_x -= 0.01
            self.zoom_y -= 0.01            
            self.mirror = false
            self.angle += 9
        else  
        self.angle = 0
        end_action   
      end       
  end
  
  #--------------------------------------------------------------------------
  # ● Update Motion Front
  #--------------------------------------------------------------------------                  
  def update_motion_front
      case @battler.motion_action[1]
        when 1..20
            self.y += 3
            self.zoom_x += 0.02
            self.zoom_y += 0.02
        when 21..40
            self.y -= 3
            self.zoom_x -= 0.02
            self.zoom_y -= 0.02            
        else  
        end_action   
      end       
  end 
  
  #--------------------------------------------------------------------------
  # ● Update Motion Round Left
  #--------------------------------------------------------------------------                    
  def update_motion_round_left
      case @battler.motion_action[1]
        when 1..15
            self.y += 3
            self.x -= 3
            self.mirror = false
        when 16..30
            self.x += 6
            self.mirror = true
        when 31..45
            self.y -= 3
            self.x -= 3
            self.mirror = false
        else  
        end_action  
      end        
  end
  
  #--------------------------------------------------------------------------
  # ● Update Motion Round Right
  #--------------------------------------------------------------------------                    
  def update_motion_round_right
      case @battler.motion_action[1]
        when 1..15
            self.y += 3
            self.x += 3
            self.mirror = true
        when 16..30
            self.x -= 6
             self.mirror = false
        when 31..45
            self.y -= 3
            self.x += 3
            self.mirror = true
        else  
        end_action    
      end    
  end  
  
  #--------------------------------------------------------------------------
  # ● End Action
  #--------------------------------------------------------------------------                      
  def end_action
      if $imported[:mog_battle_hud_ex] != nil and @battler.is_a?(Game_Actor)
         return_set(@original_set)
      else  
         return_set(@pre_set)  
      end
      @battler.motion_action = [-1,0]
  end  
  
end

#==============================================================================
#==============================================================================
# ● COLLAPSE ●
#==============================================================================
#==============================================================================

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base

  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------    
  alias mog_bact_motion_dispose dispose
  def dispose    
      @pre_image.dispose rescue nil if !@pre_image.nil?
      mog_bact_motion_dispose
  end    
  
  #--------------------------------------------------------------------------
  # ● Can Update Action
  #--------------------------------------------------------------------------    
  def can_update_collapse?
      return true
  end       
  
  #--------------------------------------------------------------------------
  # ● Update Blink
  #--------------------------------------------------------------------------      
  alias mog_motion_animation_update_blink update_blink
  def update_blink
      return if @battler.dead? or !MOG_BATTLER_MOTION::ENABLE_DAMAGE_BLINK_EFFECT
      mog_motion_animation_update_blink
  end
  
  #--------------------------------------------------------------------------
  # ● Update Collapse
  #--------------------------------------------------------------------------
  def update_collapse
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Motion Collapse
  #--------------------------------------------------------------------------    
  def execute_motion_collapse
      collapse_end if self.opacity == 0
      @battler.motion_collapse[1] += 1      
      case @battler.motion_collapse[0]
           when 0;     update_collapse_vertical
           when 1;     update_collapse_horizontal
           when 2;     update_collapse_zoom_out
           when 3;     update_collapse_zoom_in
           when 4;     update_collapse_zoom_in_out
           when 5;     update_collapse_boss_2
           when 6;     update_collpase_do_nothing
           when 7;     update_collpase_slice
           else ;      update_collapse_normal
      end
        
  end
    
  #--------------------------------------------------------------------------
  # ● Can Execute Collapse
  #--------------------------------------------------------------------------      
  def can_execute_collapse?
      return false if !@battler.dead?
      return false if @collapse_done
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Update Collapse Vertical
  #--------------------------------------------------------------------------        
  def update_collapse_vertical
      self.zoom_y += 0.1
      self.zoom_x -= 0.02         
      self.opacity -= 3    
  end
  
  #--------------------------------------------------------------------------
  # ● Update Collapse Horizontal
  #--------------------------------------------------------------------------          
  def update_collapse_horizontal
      self.zoom_x += 0.1
      self.zoom_y -= 0.02      
      self.opacity -= 3      
  end
     
  #--------------------------------------------------------------------------
  # ● Update Collapse Zoom Out
  #--------------------------------------------------------------------------            
  def update_collapse_zoom_out     
      self.zoom_x += 0.02
      self.zoom_y += 0.02     
      self.opacity -= 4   
  end
      
  #--------------------------------------------------------------------------
  # ● Update Collapse Zoom IN
  #--------------------------------------------------------------------------              
  def update_collapse_zoom_in
      self.zoom_x -= 0.01
      self.zoom_y -= 0.01      
      self.opacity -= 4            
  end
  
  #--------------------------------------------------------------------------
  # ● Update Collapse Zoom IN OUT
  #--------------------------------------------------------------------------                
  def update_collapse_zoom_in_out
      case @battler.motion_collapse[1]
           when 0..30
                self.zoom_x += 0.1
                self.zoom_y -= 0.02
                self.opacity -= 2
           else  
                self.zoom_y += 0.5
                self.zoom_x -= 0.2
                self.opacity -= 10
      end       
  end
     
  #--------------------------------------------------------------------------
  # ● Update Collapse Boss 2
  #--------------------------------------------------------------------------                  
  def update_collapse_boss_2
      self.x = @original_set[0] + rand(10) 
      self.src_rect.y -= 1
      self.opacity = 0 if self.src_rect.y < -self.bitmap.height 
  end
      
  #--------------------------------------------------------------------------
  # ● Update Collapse do nothing
  #--------------------------------------------------------------------------                    
  def update_collpase_do_nothing
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Collpase Slice
  #--------------------------------------------------------------------------      
  def update_collpase_slice    
      return if !self.visible
      if !@battler.motion_slice[0] ; @battler.motion_slice[0] = true
          @pre_image = self.bitmap
          @cw_2s = @pre_image.width ; @ch_2s = @pre_image.height
          self.bitmap = Bitmap.new(@pre_image.width * 2,@pre_image.height)
          self.ox = self.bitmap.width / 2
      end
      @battler.motion_slice[1] += 1
      @battler.motion_slice[2] += 1
      if @battler.motion_slice[2] < 60 and @battler.motion_slice[2] < @cw_2s / 2
         self.bitmap.clear
         scr_rect_1 = Rect.new(0,0,@cw_2s,@ch_2s / 2)
         self.bitmap.blt((@cw_2s / 2) - @battler.motion_slice[1],0,@pre_image,scr_rect_1)
         scr_rect_2 = Rect.new(0,@ch_2s / 2,@cw_2s,@ch_2s / 2)
         self.bitmap.blt((@cw_2s / 2) + @battler.motion_slice[1],@ch_2s / 2,@pre_image,scr_rect_2)   
      else
         self.opacity -= 3
         if self.opacity == 0 ; self.visible = false ; collapse_end ; end
      end   
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Collapse Normal
  #--------------------------------------------------------------------------                    
  def update_collapse_normal
      self.opacity -= 3
      self.blend_type = 1
  end  
  
  #--------------------------------------------------------------------------
  # ● Collapse End
  #--------------------------------------------------------------------------      
  def collapse_end
      return if @battler.motion_slice[0]
      @collapse_done = true
      return_set(@original_set) 
      self.src_rect.y = -self.bitmap.height unless @battler.motion_collapse[0] == 6
      if @battler.is_a?(Game_Enemy) and @battler.dead?
         self.visible = false ; self.opacity = 0
      end    
  end  

  #--------------------------------------------------------------------------
  # ● Revert to Normal
  #--------------------------------------------------------------------------        
  alias mog_battler_motion_revert_to_normal revert_to_normal
  def revert_to_normal
      return if @battler.motion_slice[0]
      if @collapse_done
         @collapse_done = false
         return_set(@original_set) 
      end
      mog_battler_motion_revert_to_normal 
  end  
  
end

#===============================================================================
# ■ Game Battler
#===============================================================================
class Game_Battler < Game_BattlerBase
  
  attr_accessor :bact_data
  attr_accessor :bact_sprite
  attr_accessor :pre_target
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------      
  alias mog_bact_data_motion_initialize initialize
  def initialize
      bact_clear
      mog_bact_data_motion_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● Bact Clear
  #--------------------------------------------------------------------------      
  def bact_clear
      @bact_data = [0,nil,nil,nil,false,false,0,0] ; @pre_target = nil  
  end
  
end

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------      
  alias mog_bact_motion_initialize initialize
  def initialize(viewport, battler = nil)
      @jump_count = 0 ; @jump_peak = 0 ; @move_wait_d = 0 ; @battler_dir = [false,0]
      mog_bact_motion_initialize(viewport, battler)
      if @battler.is_a?(Game_Enemy) and @battler.enemy.note =~ /<Screen X Y = \s*(\-*\d+)\s* - \s*(\-*\d+)\s*>/
         @battler.screen_x = $1.to_i ; @battler.screen_y = $2.to_i 
      end        
  end    
      
  #--------------------------------------------------------------------------
  # ● Update Position
  #--------------------------------------------------------------------------  
  alias mog_bact_motion_update_position update_position
  def update_position     
      if battler_in_motion? ; battler_in_motion ; return ; end
      if escape_phase? ; update_escape_phase ; return ; end
      mog_bact_motion_update_position    
  end
  
  #--------------------------------------------------------------------------
  # ● Battler In Motion
  #--------------------------------------------------------------------------      
  def battler_in_motion?
      return false if @battler == nil
      return false if @battler.bact_data[0] == 0
      return false if $imported[:mog_animation_plus] and $game_temp.ani_plus_wait
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Escape Phase
  #--------------------------------------------------------------------------  
  def escape_phase?
      return false if !$imported[:mog_sprite_actor]
      return false if !MOG_SPRITE_ACTOR::ESCAPE_ANIMATION 
      return false if @battler == nil
      return false if @battler.is_a?(Game_Enemy)
      return false if @battler.dead?
      return false if $game_temp.bact_phase[0] != 1
      return true 
  end  
 
  #--------------------------------------------------------------------------
  # ● Battler In Motion
  #--------------------------------------------------------------------------      
  def battler_in_motion
      old_x = self.x ; old_y = self.y
      np = [@battler.bact_data[1],@battler.bact_data[2]]
      set_move_duration(np) if @battler.bact_data[5]
      update_jump(np)
      if @pre_set != nil and @battler.is_a?(Game_Enemy) and @battler.bact_data[0] == 2
         self.zoom_x -= 0.01 if self.zoom_x > @pre_set[2]
         self.zoom_y -= 0.01 if self.zoom_y > @pre_set[3]   
      end   
      if @move_wait_d == 0
         end_bact_move(np) if self.x == np[0] and self.y == np[1]
         if $imported[:mog_sprite_actor] and !@battler.dead?
            @battler.step_animation if @battler.bact_data[6] if (old_x != self.x) or (old_y != self.y)
            @battler.bact_sprite[3] = 2 if @wp_index > 0
         end
      end
      self.z = @battler.screen_z
      self.z += 20 if !@battler.bact_data[6]
      update_in_motion_end
  end
 
  #--------------------------------------------------------------------------
  # ● Update In Motion End
  #--------------------------------------------------------------------------      
  def update_in_motion_end
      return if @move_wait_d == 0
      @move_wait_d -= 1
      return if @move_wait_d > 0
      @battler.bact_data[0] = 0      
  end
  
  #--------------------------------------------------------------------------
  # ● End Bact Move
  #--------------------------------------------------------------------------      
  def end_bact_move(np)    
      self.angle = 0 unless @battler.dead?
      @battler.screen_x = np[0] ; @battler.screen_y = np[1]
      if @battler.motion_damage[1] > 0
         @battler.motion_damage = [0,0] ; update_motion_damage                
      end  
      if @pre_set != nil
         @pre_set[0] = self.x ; @pre_set[1] = self.y
         end_action if @battler.bact_data[0] == 2
         self.angle = 0
      end   
      @move_wait_d = (@battler.bact_data[6] or @battler.bact_data[0] == 2) ? 10 : 1
      @battler.bact_sprite[3] = 0 if $imported[:mog_sprite_actor]
      if @battler.bact_data[0] == 1
         @battler.bact_action[0] = true
      elsif @battler.bact_data[0] == 2
         @battler.bact_action_clear
         self.mirror = @battler_dir[0]
         @battler.bact_sprite[0] = @battler_dir[1]
         @battler_dir = [false,4]
         @battler.bact_sprite_need_refresh = true if @battler.is_a?(Game_Actor)
      end         
  end
        
  #--------------------------------------------------------------------------
  # ● Set Move Duration
  #--------------------------------------------------------------------------      
  def set_move_duration(np)      
      set_bact_angle_m      
      self.mirror = false if @battler.bact_data[0] == 2 
      if @battler.motion_damage[1] > 0 
         @battler.motion_damage = [0,0] ; update_motion_damage    
      end
      @battler.motion_damage = [0,0]
      @battler.bact_data[5] = false
      x_plus = (self.x - np[0]).abs ; y_plus = (self.y - np[1]).abs
      p = 0
      p = @battler.is_a?(Game_Actor) ? 500 : 0 if $imported[:mog_sprite_actor] 
      e = @battler.bact_data[6] ? 200 + p : 5
      distance = Math.sqrt(x_plus + y_plus + e).round
      @jump_peak = (distance * 80 / 100).truncate
      @jump_count = @jump_peak * 2
      if @pre_set != nil
         @pre_set[0] = self.x ; @pre_set[1] = self.y ; @pre_set[4] = self.mirror
      end   
      @battler.bact_sprite[3] = 2 if $imported[:mog_sprite_actor]  
      @battler.bact_action_clear if @battler.bact_data[0] == 2
      @move_wait_d = 0
      @wp_index = 0 if @battler.bact_data[0] == 1      
  end
  
  #--------------------------------------------------------------------------
  # ● Set Bact Angle M
  #--------------------------------------------------------------------------      
  def set_bact_angle_m
      @battler_dir = [self.mirror,@battler.bact_sprite[0]] if @battler.bact_data[0] == 1  
      return if @battler.bact_data[6] and [2,4].include?(@battler.bact_sprite[5])
      if @battler.bact_data[7] >= 0 ; else
         self.angle = @battler.bact_data[0] == 2 ? 350 : 5
         self.mirror = true if @battler.is_a?(Game_Enemy) and MOG_BATTLER_MOTION::BATTLER_MIRROR_DIRECTION
         @battler.bact_sprite[0] = 4 unless [2,8].include?( @battler.bact_sprite[0])
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Update Jump
  #--------------------------------------------------------------------------      
  def update_jump(np)
      return if $game_temp.bc_target_dmg[1] > 0
      @jump_count -= 1 if @jump_count > 0
      self.x = (self.x * @jump_count + np[0]) / (@jump_count + 1.0)
      self.y = ((self.y * @jump_count + np[1]) / (@jump_count + 1.0)) - jump_height
  end
  
  #--------------------------------------------------------------------------
  # ● Jump Height
  #--------------------------------------------------------------------------      
  def jump_height
      return 0 if @battler.bact_data[6]
      return (@jump_peak * @jump_peak - (@jump_count - @jump_peak).abs ** 2) / 40
  end
  

  #--------------------------------------------------------------------------
  # ● Can Update Battler Motion
  #--------------------------------------------------------------------------      
  alias mog_bact_can_update_battler_motion? can_update_battler_motion?
  def can_update_battler_motion?
      return false if @battler.bact_data[0] != 0
      mog_bact_can_update_battler_motion?
  end
    
  #--------------------------------------------------------------------------
  # ● Can Update idle
  #--------------------------------------------------------------------------    
  alias mog_bact_can_update_idle? can_update_idle?
  def can_update_idle?
      return false if @battler.bact_data[1] != nil
      mog_bact_can_update_idle?
  end    

end  

#===============================================================================
# ■ Scene Battle
#===============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Execute Action
  #--------------------------------------------------------------------------      
  alias mog_bact_execute_action execute_action
  def execute_action
      @cp_members = []
      if @subject != nil
         @subject.bact_action_clear 
         item = @subject.current_action.item rescue nil
         @subject.bact_skill = item if item != nil 
         if $imported[:mog_atb_system] and execute_cooperation_skill?
            @cp_members = current_cp_members
            for battler in @cp_members
                battler.bact_skill = item if item != nil
           end
         end         
      end
      execute_bact_move if execute_bact_move?
      if $imported[:mog_sprite_actor] and $imported[:mog_animation_plus]
         $game_temp.ani_plus_wait = false  ; execute_cast_animation
      end
      mog_bact_execute_action
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Bact Move
  #--------------------------------------------------------------------------      
  def execute_bact_move?
      item = @subject.current_action.item rescue nil
      return false if item == nil
      return false if item.is_a?(RPG::Skill) and @subject.is_a?(Game_Actor) and item.id == @subject.guard_skill_id
      targets = @subject.current_action.make_targets.compact rescue nil
      @subject.pre_target = targets
      for battler in @cp_members ; battler.pre_target = targets ; end      
      scy = @subject.screen_x rescue nil ; scx = targets[0].screen_x rescue nil
      return false if scx == nil or scy == nil
      return false if $imported[:mog_battle_hud_ex] and SceneManager.face_battler?
      return false if @act_enabled != nil
      return true
  end

  #--------------------------------------------------------------------------
  # ● Long Range?
  #--------------------------------------------------------------------------      
  def long_range?(item)
      return false if item == nil
      if @subject.is_a?(Game_Actor) and item.is_a?(RPG::Skill) and 
         item.id == @subject.attack_skill_id and  @subject.equips[0] != nil
      return true if @subject.equips[0].note =~ /<Icon Angle = (\d+)>/i
      end  
      return false if item.note =~ /<Move to Target>/
      return false if item.note =~ /<Move to Target x\s*(\-*\d+)\s* y\s*(\-*\d+)\s*>/
      return true if [2,8,10].include?(item.scope)      
      return true
  end

  #--------------------------------------------------------------------------
  # ● Set BC Skill Type
  #--------------------------------------------------------------------------    
  def set_bc_skill_type
      item = @subject.current_action.item rescue nil
      return if item == nil
      return if item.is_a?(RPG::Skill) and item.stype_id != 1
      return if item.is_a?(RPG::Item) and item.itype_id != 1
      targets = @subject.current_action.make_targets.compact
      set_battle_camera_animation(targets, item.animation_id)
  end
  #--------------------------------------------------------------------------
  # ● Execute Bact Move
  #--------------------------------------------------------------------------      
  def execute_bact_move
      return if @subject.bact_skill == nil
      @act_enabled = true
      item = @subject.bact_skill
      if $imported[:mog_sprite_actor] and @subject.is_a?(Game_Actor) and long_range?(item)
          execute_bact_move_sprite_actor
      else   
         unless @subject.is_a?(Game_Enemy) and long_range?(item)
         targets = @subject.current_action.make_targets.compact
         targets[0] = @subject.primary_target if !@subject.primary_target.nil?
         exy = [0,0]
         if item.note =~ /<Move to Target x\s*(\-*\d+)\s* y\s*(\-*\d+)\s*>/
            exy = [$1.to_i,$2.to_i]
         end
         @subject.bact_data = [1,targets[0].screen_x + exy[0],targets[0].screen_y + exy[1],@subject.screen_x,@subject.screen_y,0,0,0]
         @subject.bact_data[5] = true
         @subject.bact_data[6] = false
         @subject.bact_data[7] = targets[0].screen_x - @subject.screen_x
         if @cp_members != nil
         for battler in @cp_members             
             battler.bact_data = [1,targets[0].screen_x,targets[0].screen_y,battler.screen_x,battler.screen_y,0,0,0]
             battler.bact_data[5] = true
             battler.bact_data[6] = false
             battler.bact_data[7] = targets[0].screen_x - battler.screen_x
          end          
          end
          execute_action_bact
         end
      end      
  end    
  
  #--------------------------------------------------------------------------
  # ● Execute Bact Move Sprite Actor
  #--------------------------------------------------------------------------      
  def execute_bact_move_sprite_actor
      ns = $imported[:mog_sprite_actor] ? $game_party.battlers_m_steps : 32
      if @subject.is_a?(Game_Enemy)
         targets = @subject.pre_target rescue nil
         targets = @subject.current_action.make_targets.compact if targets == nil
         if [2,8].include?($game_party.battle_members[0].bact_sprite[0])
            if targets[0].screen_y >= @subject.screen_y ; @subject.bact_sprite[0] = 2; end
            if targets[0].screen_y < @subject.screen_y ; @subject.bact_sprite[0] = 8; end
         else  
            if targets[0].screen_x >= @subject.screen_x ; @subject.bact_sprite[0] = 6; end
            if targets[0].screen_x < @subject.screen_x ; @subject.bact_sprite[0] = 4; end
         end
      end
      case @subject.bact_sprite[0]
           when 2 ; x = @subject.screen_x ; y = @subject.screen_y + ns
           when 4 ; x = @subject.screen_x - ns ; y = @subject.screen_y             
           when 6 ; x = @subject.screen_x + ns ; y = @subject.screen_y             
           when 8 ; x = @subject.screen_x ; y = @subject.screen_y - ns
      end       
      @subject.bact_data = [1,x,y,@subject.screen_x,@subject.screen_y,0,0,0,0]
      @subject.bact_data[5] = true ; @subject.bact_data[6] = true  
      for battler in @cp_members
          case battler.bact_sprite[0]
               when 2 ; x = battler.screen_x ; y = battler.screen_y + ns
               when 4 ; x = battler.screen_x - ns ; y = battler.screen_y             
               when 6 ; x = battler.screen_x + ns ; y = battler.screen_y             
               when 8 ; x = battler.screen_x ; y = battler.screen_y - ns
          end          
          battler.bact_data = [1,x,y,battler.screen_x,battler.screen_y,0,0,0,0]
          battler.bact_data[5] = true
          battler.bact_data[6] = true    
      end
      execute_action_bact  
  end
         
  #--------------------------------------------------------------------------
  # ● Process Action End
  #--------------------------------------------------------------------------      
  alias mog_bact_f_use_item use_item
  def use_item
      mog_bact_f_use_item
      motion_move_to_origin if @act_enabled
  end
  
  #--------------------------------------------------------------------------
  # ● Process Turn End
  #--------------------------------------------------------------------------      
  alias mog_bact_f_turn_end turn_end
  def turn_end
      motion_move_to_origin if @act_enabled
      mog_bact_f_turn_end
  end
  
  #--------------------------------------------------------------------------
  # ● Motion Move to Origin
  #--------------------------------------------------------------------------      
  def motion_move_to_origin
      if $imported[:mog_battle_camera]         
         $game_temp.bc_in_action[3] = false
         $game_temp.bc_in_turn = false ; clear_target_camera
      end
      process_wait_end
      process_bact_end if @subject.bact_data[1] != nil
      @subject.bact_action_clear
      @subject.pre_target = nil
      if @cp_members != nil
      for battler in @cp_members
          battler.bact_action_clear
          battler.pre_target = nil
      end
      end
      @act_enabled = nil  
  end
      
  #--------------------------------------------------------------------------
  # ● Turn End
  #--------------------------------------------------------------------------
  alias mog_bact_turn_end turn_end
  def turn_end
      @subject.return_to_orign if @subject.is_a?(Game_Actor) and $imported[:mog_sprite_actor]
      if @cp_members != nil
      for battler in @cp_members 
          battler.return_to_orign if $imported[:mog_sprite_actor]
      end
      end      
      mog_bact_turn_end
  end
  
  #--------------------------------------------------------------------------
  # ● Process Wait End
  #--------------------------------------------------------------------------      
  def process_wait_end
      return if $game_temp.bact_wait_d == 0
      loop do ; update_basic ; $game_temp.bact_wait_d -= 1 ; break if $game_temp.bact_wait_d == 0
      end    
  end
  
  #--------------------------------------------------------------------------
  # ● Process Bact End
  #--------------------------------------------------------------------------      
  def process_bact_end      
      $game_temp.bc_in_action[6] = false if $imported[:mog_battle_camera]
      @subject.bact_data[0] = 2
      @subject.bact_data[1] = @subject.bact_data[3]
      @subject.bact_data[2] = @subject.bact_data[4]
      @subject.bact_data[5] = true
      @subject.wp_animation = [false,false] if $imported[:mog_sprite_actor]
      if @cp_members != nil
      for battler in @cp_members
          battler.bact_data[0] = 2
          battler.bact_data[1] = battler.bact_data[3]
          battler.bact_data[2] = battler.bact_data[4]
          battler.bact_data[5] = true
          battler..wp_animation = [false,false] if $imported[:mog_sprite_actor]
          battler.bact_sprite_need_refresh = true
      end       
      end
      execute_action_bact unless @subject.is_a?(Game_Actor) and $game_party.all_dead?
      @subject.bact_clear
      if @cp_members != nil
      for battler in @cp_members ; battler.bact_clear ; end
      end
  end     
       
  #--------------------------------------------------------------------------
  # ● Execute Action Bact
  #--------------------------------------------------------------------------      
  def execute_action_bact
      return if @subject == nil      
      loop do ; update_basic ; break if @subject.bact_data[0] == 0 ; end
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Cooperation Skill?
  #--------------------------------------------------------------------------  
  def execute_cooperation_skill?
      return false if !@subject.is_a?(Game_Actor)
      item = @subject.bact_skill rescue nil
      return false if item == nil
      return false if !BattleManager.cskill_usable?(item.id,@subject.id)
      return true
  end  
 
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------  
  alias mog_bact2_use_item use_item
  def use_item
      if $imported[:mog_sprite_actor]
      target = @subject.pre_target[0] rescue nil
      if target != nil and target.dead?
         if @subject.is_a?(Game_Actor) ; return unless target.is_a?(Game_Actor)
         else ; return unless target.is_a?(Game_Enemy)
         end   
      end
      end
      mog_bact2_use_item
      @subject.wp_animation = [false,false] if $imported[:mog_sprite_actor]
  end  
  
end

#===============================================================================
# ■ Game Action
#===============================================================================
class Game_Action

  #--------------------------------------------------------------------------
  # ● Clear
  #--------------------------------------------------------------------------
  alias mog_bact_clear clear
  def clear
      @subject.pre_target = nil rescue nil
      mog_bact_clear
  end  
   
  #--------------------------------------------------------------------------
  # ● Make Targets
  #--------------------------------------------------------------------------
  alias mog_bact_make_targets make_targets
  def make_targets
      return @subject.pre_target if @subject != nil and @subject.pre_target != nil
      mog_bact_make_targets
  end

end