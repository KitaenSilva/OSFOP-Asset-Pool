#==============================================================================
# +++ MOG - ATB System  (v 6.1) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Sistema de batalha ativo.
#==============================================================================

#==============================================================================
# NOTA 1
#==============================================================================
# O script não vem com medidor de ATB incluído, será necessário usar scripts
# add-ons para adicionar os medidores.
# 
# Battle Hud EX
# Ayesha ATB Gauge
# Schala ATB Gauge
#
#==============================================================================
# NOTA 2
#==============================================================================
# A janela de LOG está desativada para deixar a batalha mais dinâmica.
# Portanto é necessário usar algum script de Damage Popup para ver os danos
# causados no alvo
#==============================================================================

#==============================================================================
# ● ATB SYSTEM
#==============================================================================
# A velocidade de AT é baseaddo na agilidade do Battler.
# Em caso de batalhas preventivas (Preemptive) os aliados começarão com AT em
# 80% e os inimigos começarão com AT em 0 (Zero)
# Em batalhas surpresas (Surprise) é o inverso das batalhas preventivas.
# Em batalhas normais todos os battlers começarão com AT em 40%.
#==============================================================================
# ● CAST TIME
#==============================================================================
# Para definir uma habilidade ou item com a função de Cast Time basta definir
# o valor da velocidade (Speed) diferente de 0 (Zero).
#
# NOTA - Não é possível ativar 2 ou mais habilidades com a função Cast Time no
# mesmo turno. (Caso você esteja usando características de Multi Action em
# seu projeto.)
#==============================================================================

#==============================================================================
# COMANDOS DE EVENTOS
#==============================================================================
# 
# atb_type(type)                - Define o tipo de ATB.
# atb_max(X)                    - Define o tempo de ATB.
# atb_stop                      - Pausa o ATB e o Turno.
# atb_turn_speed(X)             - Define o tempo do turno.
# atb_turn_stop                 - Pausa apenas o turno.
# atb_turn_reset                - Zera o tempo do turno atual.
# atb_sprite_turn(false)        - Ativar/Desativa o número do turno.
#
#==============================================================================

#==============================================================================
# Histórico
#==============================================================================
# v6.1 - Correção do crash na seleção de skills vazias.
# v6.0 - Melhorias no sistema do evento comum.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_atb_system] = true

#==============================================================================
# Cooperation Skills
#==============================================================================
module MOG_COOPERATION_SKILLS
  COOPERATION_SKILLS = []  # ☢CAUTION!!☢ Don't Touch.^_^
  #-------------------------------------------------------------------------- 
  # Definição das skills 
  #
  # COOPERATION_SKILLS[SKILL_ID] = [ACTOR_ID, ACTOR_ID, ACTOR_ID, ACTOR_ID]
  #-------------------------------------------------------------------------- 
 
  # COOPERATION_SKILLS[51] = [2,4]     # Fire 
  # COOPERATION_SKILLS[66] = [2,4,3]   # Quake 
  COOPERATION_SKILLS[104] = [1,5]      # Ouka Mugen jin
  COOPERATION_SKILLS[143] = [3,4]      # Flare 
  COOPERATION_SKILLS[151] = [1,2,3,4]  # Ultima  
  COOPERATION_SKILLS[153] = [2,4]      # W Ultima End
  
  
  #-------------------------------------------------------------------------- 
  #Definição da animação ao ativar as habilidades de cooperação.
  #-------------------------------------------------------------------------- 
  COOPERATION_SKILL_ANIMATION = 49  
end

#==============================================================================
# GENERAL SETTING
#==============================================================================
module MOG_ATB_SYSTEM
  #-------------------------------------------------------------------------- 
  # Definição do tipo de ATB
  #
  # 0 - Wait
  # 1 - Semi Active
  # 2 - Full ACtive
  # 
  # É possível mudar o tipo de ATB no meio do jogo usando o código abaixo.
  #
  # atb_type(type)
  # 
  #--------------------------------------------------------------------------
  ATB_TYPE = 1
  #--------------------------------------------------------------------------
  #Som quando o sistema ATB estiver no maximo
  #--------------------------------------------------------------------------
  SE_ACTIVE = "Decision2"
  #--------------------------------------------------------------------------
  # Definição do valor de ATB para ativar a ação.
  # É possível mudar o valor no meio do jogo usando o código abaixo.
  #
  # atb_max(X)
  #
  #--------------------------------------------------------------------------
  ATB_MAX = 5000
  #--------------------------------------------------------------------------
  # Definição do tipo de duração (Contagem/formula) de um turno.
  # Essa definição influência na ativação dos eventos de batalha.
  # (BATTLE EVENTS)
  #
  # 0 - Duração de um turno é um valor fixo.
  # 1 - Duração de um turno é multiplicado pela quantidade de batllers.
  # 2 - Duração de um turno é baseado na média de agilidade dos battlers.
  #
  #--------------------------------------------------------------------------
  TURN_DURATION_TYPE = 0
  #--------------------------------------------------------------------------
  # Definição de valor usado para calcular a duração de um turno.
  #--------------------------------------------------------------------------
  TURN_DURATION = 500
  #--------------------------------------------------------------------------
  # Definição da animação quando o battler usa habilidades de carregamento.
  #--------------------------------------------------------------------------
  CAST_ANIMATION = 49
  #--------------------------------------------------------------------------
  # Ativar a mensagem inicial com os nomes dos inimigos.
  #--------------------------------------------------------------------------
  MESSAGE_ENEMY_APPEAR = false
  #--------------------------------------------------------------------------
  # Ativar o botão de pular turno.
  #--------------------------------------------------------------------------
  ENABLE_BUTTON_NEXT_ACTOR = true
  #--------------------------------------------------------------------------
  # Definição do botão pular turno.
  #--------------------------------------------------------------------------
  BUTTON_NEXT_ACTOR_RIGHT = :R
  BUTTON_NEXT_ACTOR_LEFT = :L
  #--------------------------------------------------------------------------
  # Apresentar o Turno. 
  # É possível desativar / ativar o turno usando o código abaixo.
  #
  # atb_sprite_turn(false) 
  #
  #--------------------------------------------------------------------------
  DISPLAY_TURN_NUMBER = false
  #--------------------------------------------------------------------------
  # Definição da palavra Turno.
  #--------------------------------------------------------------------------
  TURN_WORD = "Turn "
  #--------------------------------------------------------------------------
  # Tamanho da fonte
  #--------------------------------------------------------------------------
  TURN_NUMBER_FONT_SIZE = 24 
  #--------------------------------------------------------------------------
  # Ativar bold.
  #--------------------------------------------------------------------------
  TURN_NUMBER_FONT_BOLD = true
  #--------------------------------------------------------------------------
  # Posição Z.
  #--------------------------------------------------------------------------
  TURN_NUMBER_Z = 100
  #--------------------------------------------------------------------------
  # Posição X & Y.
  #--------------------------------------------------------------------------
  TURN_NUMBER_POS = [5,0]    
end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp 
  
  attr_accessor :atb_in_turn
  attr_accessor :atb_wait
  attr_accessor :atb_user
  attr_accessor :atb_stop
  attr_accessor :atb_actor_order
  attr_accessor :atb_break_duration
  attr_accessor :battle_end
  attr_accessor :battle_end2
  attr_accessor :turn_duration_clear
  attr_accessor :refresh_battle_atb
  attr_accessor :end_phase_duration
  attr_accessor :atb_frame_skip
  attr_accessor :refresh_actor_command  
  attr_accessor :refresh_target_windows
  attr_accessor :refresh_item_window
  attr_accessor :actor_command_index
  attr_accessor :actor_process_event
  attr_accessor :break_command
  attr_accessor :hwindow_atb
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------         
  alias mog_atb_temp_initialize initialize
  def initialize
      @atb_in_turn = false
      @atb_wait = false
      @atb_break_duration = 0
      @atb_stop = [false,false]
      @atb_actor_order = []
      @turn_duration_clear = false
      @battle_end = true
      @battle_end2 = true
      @refresh_battle_atb = false
      @end_phase_duration = [false,0]
      @atb_frame_skip = 0
      @refresh_actor_command = false
      @refresh_target_windows = [false,false]
      @actor_command_index = 0
      @refresh_item_window = false
      @break_command = false
      @actor_process_event = nil
      @hwindow_atb = false
      mog_atb_temp_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● Sprite Visible
  #--------------------------------------------------------------------------    
  def sprite_visible
      return false if $game_message.visible
      return false if $game_temp.battle_end
      return true
  end   
  
  #--------------------------------------------------------------------------
  # ● add Order
  #--------------------------------------------------------------------------    
  def add_order(battler)
      return if battler == nil
      return if battler.is_a?(Game_Enemy)
      $game_temp.atb_actor_order.push(battler)
  end  
    
  #--------------------------------------------------------------------------
  # ● Remove Order
  #--------------------------------------------------------------------------    
  def remove_order(battler)
      return if battler == nil
      return if battler.is_a?(Game_Enemy)
      $game_temp.atb_actor_order.delete(battler) rescue nil
  end  
  
end

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  
  attr_accessor :atb_max
  attr_accessor :atb_type
  attr_accessor :atb_turn_duration
  attr_accessor :atb_sprite_turn
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------         
  alias mog_at_system_initialize initialize
  def initialize
      @atb_max = [[MOG_ATB_SYSTEM::ATB_MAX, 999999].min, 1500].max
      @atb_type = MOG_ATB_SYSTEM::ATB_TYPE ; @atb_sprite_turn = true
      @atb_turn_duration = [0,
      [[MOG_ATB_SYSTEM::TURN_DURATION, 999999].min, 50].max]
      mog_at_system_initialize
  end
  
end 

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● ATB Type
  #--------------------------------------------------------------------------         
  def atb_type(type)
      $game_system.atb_type = type
  end
  
  #--------------------------------------------------------------------------
  # ● ATB Max
  #--------------------------------------------------------------------------         
  def atb_max(value)
      $game_system.atb_max = [[value, 999999].min, 1500].max
  end
  
  #--------------------------------------------------------------------------
  # ● ATB Sprite Turn
  #--------------------------------------------------------------------------         
  def atb_sprite_turn(value = true)
      $game_system.atb_sprite_turn = value
  end  
  
  #--------------------------------------------------------------------------
  # ● ATB Turn Speed
  #--------------------------------------------------------------------------         
  def atb_turn_speed(value = 400)
      $game_system.atb_turn_duration[1] = [[value, 999999].min, 50].max
  end
  
  #--------------------------------------------------------------------------
  # ● ATB force Turn
  #--------------------------------------------------------------------------         
  def atb_force_turn(value)
      $game_troop.turn_count = value
  end
  
  #--------------------------------------------------------------------------
  # ● ATB Turn Reset
  #--------------------------------------------------------------------------         
  def atb_turn_reset
      $game_system.atb_turn_duration[0] = 0
  end
  
  #--------------------------------------------------------------------------
  # ● Command 339
  #--------------------------------------------------------------------------         
  def command_339
      iterate_battler(@params[0], @params[1]) do |battler|
      next if battler.death_state?
      battler.turn_clear
      if BattleManager.actor!= nil and battler == BattleManager.actor
         BattleManager.actor.turn_clear
         $game_temp.break_command = true
         BattleManager.command_selection_clear
      end
      battler.force_action(@params[2], @params[3])
      BattleManager.force_action(battler)
      Fiber.yield while BattleManager.action_forced?
      end  
  end
    
end

#==============================================================================
# ■ Game Troop
#==============================================================================
class Game_Troop < Game_Unit

  #--------------------------------------------------------------------------
  # ● Can Interpreter Running?
  #--------------------------------------------------------------------------         
  def can_interpreter_running?(tend = false)      
      BattleManager.turn_end if tend
      return true if $game_temp.common_event_reserved?
      return false if @interpreter.running?      
      return false if @interpreter.setup_reserved_common_event
      troop.pages.each do |page|
         next unless conditions_met?(page)
         @current_page = page
         return true
      end    
      return false
   end    
      
  #--------------------------------------------------------------------------
  # ● Can Interpreter Hide Window?
  #--------------------------------------------------------------------------    
  def can_interpreter_hide_window?      
      return false if @current_page == nil
      @current_page.list.each do |l|
      if l.code.between?(101,105) ; @current_page = nil ; return true ; end
      end
      @current_page = nil
      return false
   end    
      
  #--------------------------------------------------------------------------
  # ● Can Interpreter Hide Window 2?
  #--------------------------------------------------------------------------    
  def can_interpreter_hide_window_2?
      return false if $game_temp.common_event_id == 0
      common_event = $data_common_events[$game_temp.common_event_id] rescue nil
      return false if common_event.nil?
      common_event.list.each do |l|
      return true if l.code.between?(101,105) 
      end
      return false 
  end 
  
  #--------------------------------------------------------------------------
  # ● Set Turn
  #--------------------------------------------------------------------------         
  def set_turn(turn_value)
      @turn_count = turn_value
  end 
      
end

#==============================================================================
# ■ Window Base
#==============================================================================
class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------         
  alias mog_atb_wbase_initialize initialize
  def initialize(x, y, width, height)
      mog_atb_wbase_initialize(x, y, width, height)
      @pre_data = [0,self.visible,self.active,self.opacity]
  end
  
  #--------------------------------------------------------------------------
  # ● Hide All
  #--------------------------------------------------------------------------         
  def hide_all
      @index = 0 if @index ; self.visible = false ; self.active = false
      update
  end
  
  #--------------------------------------------------------------------------
  # ● Record Data
  #--------------------------------------------------------------------------         
  def record_data
      @pre_data = [@index ,self.visible ,self.active ,self.opacity]
      update
  end
  
  #--------------------------------------------------------------------------
  # ● Restore Data
  #--------------------------------------------------------------------------         
  def restore_data
      @index = @pre_data[0] if @index ; self.visible = @pre_data[1]
      self.active = @pre_data[2] ; self.opacity = @pre_data[3]
      update
  end 
  
end

#==============================================================================
# ■ Window Selectable
#==============================================================================
class Window_Selectable < Window_Base
  
  attr_accessor :pre_data
  
  #--------------------------------------------------------------------------
  # ● Row Max
  #--------------------------------------------------------------------------
  def row_max
      cm = col_max > 0 ? col_max : 1
      [(item_max + cm - 1) / cm, 1].max
  end  
  
  #--------------------------------------------------------------------------
  # ● Row
  #--------------------------------------------------------------------------
  def row
      cm = col_max > 0 ? col_max : 1
      index / cm
  end  
  
  #--------------------------------------------------------------------------
  # ● Item Width
  #--------------------------------------------------------------------------
  def item_width
      cm = col_max > 0 ? col_max : 1
      (width - standard_padding * 2 + spacing) / cm - spacing
  end  
  
  #--------------------------------------------------------------------------
  # ● Item Rect
  #--------------------------------------------------------------------------
  def item_rect(index)
      cm = col_max > 0 ? col_max : 1
      rect = Rect.new
      rect.width = item_width
      rect.height = item_height
      rect.x = index % cm * (item_width + spacing)
      rect.y = index / cm * item_height
      rect
  end  
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #-------------------------------------------------------------------------
  alias mog_atb_sel_initialize initialize
  def initialize(x, y, width, height)
      mog_atb_sel_initialize(x, y, width, height)
      @pre_data = [@index,self.visible,self.active,self.opacity]
  end  
  
  #--------------------------------------------------------------------------
  # ● Process Cursor Move
  #--------------------------------------------------------------------------
  alias mog_atb_wactor_process_cursor_move process_cursor_move
  def process_cursor_move
      return if  SceneManager.scene_is?(Scene_Battle) and skip_command?
      mog_atb_wactor_process_cursor_move
  end
 
  #--------------------------------------------------------------------------
  # ● Process Handling
  #--------------------------------------------------------------------------
  alias mog_atb_wactor_process_handling process_handling
  def process_handling  
      return if SceneManager.scene_is?(Scene_Battle) and skip_command?
      mog_atb_wactor_process_handling
  end    
    
  #--------------------------------------------------------------------------
  # ● Process Handling
  #--------------------------------------------------------------------------
  def skip_command?
      return false if self.is_a?(Window_VictorySpoils) if $imported["YEA-VictoryAftermath"]
      return true if !$game_temp.sprite_visible
      return true if $game_temp.battle_end
      return true if $game_temp.end_phase_duration[1] > 0
      return true if BattleManager.actor == nil
      return false  
  end  
  
end

#==============================================================================
# ■ Window_ActorCommand
#==============================================================================
class Window_ActorCommand < Window_Command
  
  attr_accessor :actor
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  alias mog_atb_ac_update update
  def update
      mog_atb_ac_update
      $game_temp.actor_command_index = self.index if self.active
  end
  
  if MOG_ATB_SYSTEM::ENABLE_BUTTON_NEXT_ACTOR
  #--------------------------------------------------------------------------
  # ● Process_Cursor Move
  #--------------------------------------------------------------------------
  def process_cursor_move
      return unless cursor_movable?
      last_index = @index
      cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
      cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
      cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
      cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
      Sound.play_cursor if @index != last_index
  end
  end
  
  if $imported["YEA-BattleEngine"] 
  #--------------------------------------------------------------------------
  # ● Process_dir4
  #--------------------------------------------------------------------------
  def process_dir4
  end
  
  #--------------------------------------------------------------------------
  # ● Process_dir6
  #--------------------------------------------------------------------------
  def process_dir6
  end  
  end  
  
  #--------------------------------------------------------------------------
  # ● Process Cursor Move
  #--------------------------------------------------------------------------  
  alias mog_atb_bm_process_cursor_move process_cursor_move
  def process_cursor_move
      return if SceneManager.scene_is?(Scene_Battle) and BattleManager.actor == nil
      mog_atb_bm_process_cursor_move
  end
  
  #--------------------------------------------------------------------------
  # ● Process Handling
  #--------------------------------------------------------------------------    
  alias mog_atb_bm_process_handling process_handling
  def process_handling
      return if SceneManager.scene_is?(Scene_Battle) and BattleManager.actor == nil
      mog_atb_bm_process_handling
  end  
  
end

#==============================================================================
# ■ Window_BattleEnemy
#==============================================================================
class Window_BattleEnemy < Window_Selectable
 
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------  
  alias mog_atb_battle_enemy_update update
  def update
      return if enemy == nil      
      mog_atb_battle_enemy_update
  end
  
end

#==============================================================================
# ■ Window BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  
  #--------------------------------------------------------------------------
  # ● Display Added States
  #--------------------------------------------------------------------------    
  def display_added_states(target)
      return if target.turn_collapse
      target.result.added_state_objects.each do |state|
         state_msg = target.actor? ? state.message1 : state.message2
         if state.id == target.death_state_id
            target.perform_collapse_effect if target.hp == 0
         end
         next if state_msg.empty?
         replace_text(target.name + state_msg)
         target.turn_collapse = true if state.id == target.death_state_id
         wait
         wait_for_effect
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------    
  def refresh
  end  

  #--------------------------------------------------------------------------
  # ● Message Speed
  #--------------------------------------------------------------------------    
  def message_speed
      return 10 if $imported["YEA-BattleEngine"]
      return 5
  end

  #--------------------------------------------------------------------------
  # * Wait for Effect
  #--------------------------------------------------------------------------
  def wait_for_effect
      return false
  end  

end

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------      
  alias mog_atb_sprite_update update
  def update      
      mog_atb_sprite_update
      clear_atb_battler_dead if clear_atb_battler_dead?
  end
  
  #--------------------------------------------------------------------------
  # ● Init Visibility
  #--------------------------------------------------------------------------      
  alias mog_atb_init_visibility init_visibility
  def init_visibility
      self.visible = true
      self.opacity = 255 if @battler.alive?
      mog_atb_init_visibility
  end
  
  #--------------------------------------------------------------------------
  # ● Clear ATB Battler
  #--------------------------------------------------------------------------      
  def clear_atb_battler_dead?
      return false if !self.visible
      return false if @battler.nil?
      return false if !@battler.dead?
      return false if @battler.is_a?(Game_Actor)
      return false if !@effect_type.nil?
      return false if $imported[:mog_battler_motion] and !@collapse_done
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Clear ATB Battler Dead
  #--------------------------------------------------------------------------      
  def clear_atb_battler_dead
      self.opacity = 0
      self.visible = false
      @battler.atb_initial
  end
  
end

#==============================================================================
# ■ Game Battler Base
#==============================================================================
class Game_BattlerBase  
  
  attr_accessor :hidden
  
  #--------------------------------------------------------------------------
  # ● Inputable?
  #--------------------------------------------------------------------------             
  def inputable?
      normal? && !auto_battle? && self.atb_max?
  end
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
   attr_accessor :atb
   attr_accessor :atb_max 
   attr_accessor :atb_cast
   attr_accessor :atb_action
   attr_accessor :atb_turn_duration
   attr_accessor :atb_escape
   attr_accessor :next_turn
   attr_accessor :turn_collapse
   attr_accessor :actions
   
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------       
   alias mog_at_system_initialize initialize
   def initialize
       mog_at_system_initialize
       atb_init_setup
   end
   
  #--------------------------------------------------------------------------
  # ● Atb Init Setup
  #--------------------------------------------------------------------------       
   def atb_init_setup
       @atb = 0
       @atb_max = $game_system.atb_max
       @atb_cast = []
       @atb_turn_duration = 0
       @next_turn = false
       @atb_escape = false
       @turn_collapse = false
       @wait_motion = $imported[:mog_battler_motion] != nil ? true : false
   end     
   
  #--------------------------------------------------------------------------
  # ● Atb
  #--------------------------------------------------------------------------          
   def atb
       return 0 if self.hp == 0
       return [[@atb, atb_max].min, 0].max
   end  
   
  #--------------------------------------------------------------------------
  # ● Max ATB
  #--------------------------------------------------------------------------          
   def atb_max
       return [$game_system.atb_max,100].max
   end    
   
  #--------------------------------------------------------------------------
  # ● Max AT?
  #--------------------------------------------------------------------------          
   def atb_max?
       self.atb >= atb_max
   end
   
  #--------------------------------------------------------------------------
  # ● Atb Speed
  #--------------------------------------------------------------------------          
   def atb_speed
       return self.agi
   end
  
  #--------------------------------------------------------------------------
  # ● ATB Update
  #--------------------------------------------------------------------------    
  def atb_update?
      return false if restriction >= 4
      return false if self.hp == 0
      return false if self.hidden
      return false if @wait_motion && $game_temp.battler_in_motion
      return true
  end

  #--------------------------------------------------------------------------
  # ● ATB Update
  #--------------------------------------------------------------------------    
  def atb_update
      return if !atb_update?
      if self.atb_cast.empty?
         if !atb_max?
            self.atb += self.atb_speed
            execute_atb_max_effect if atb_max?
         end   
      else   
         self.atb_cast[1] -= 1
         execute_cast_action if self.atb_cast[1] <= 0
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Atb Max Effect
  #--------------------------------------------------------------------------    
  def execute_atb_max_effect
      $game_temp.refresh_item_window = true if need_refresh_item_window?
      $game_temp.add_order(self)
  end
  
  #--------------------------------------------------------------------------
  # ● Need Refresh Item Window?
  #--------------------------------------------------------------------------    
  def need_refresh_item_window?
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Cast Action
  #--------------------------------------------------------------------------    
  def execute_cast_action
      self.next_turn = true ; self.atb = self.atb_max ; self.atb_cast.clear
  end
  
  #--------------------------------------------------------------------------
  # ● Atb Clear
  #--------------------------------------------------------------------------    
  def atb_clear
      self.atb = 0 ; self.atb_cast.clear ; self.turn_collapse = false
  end
    
  #--------------------------------------------------------------------------
  # ● Atb Initial
  #--------------------------------------------------------------------------    
  def atb_initial
      @atb = 0 ; @atb_cast = [] ; @atb_turn_duration = 0 
      @atb_escape = false ; @next_turn = false ; clear_actions
  end     
       
  #--------------------------------------------------------------------------
  # ● Movable ATB
  #--------------------------------------------------------------------------    
  def movable_atb?
      return false if !atb_max?
      return false if self.dead?
      return false if self.restriction != 0
      return false if self.next_turn
      return false if !self.atb_cast.empty?
      return true 
  end
  
  #--------------------------------------------------------------------------
  # ● Item Apply
  #--------------------------------------------------------------------------  
  alias mog_atb_item_apply item_apply
  def item_apply(user, item)      
      pre_item = self.current_action.item rescue nil
      mog_atb_item_apply(user, item)      
      if SceneManager.scene_is?(Scene_Battle)
         effect_for_dead if self.dead?
         atb_after_damage(pre_item)
      end   
  end  

  #--------------------------------------------------------------------------
  # ● ATB After Damage
  #--------------------------------------------------------------------------  
  def atb_after_damage(pre_item = nil)
      $game_temp.break_command = true if can_damage_break_command?
      turn_clear if self.restriction == 4 or self.dead?
      $game_temp.remove_order(self) if self.restriction > 0 or self.dead?
      $game_temp.battle_end2 = true if $game_troop.all_dead? or $game_party.all_dead?
  end
 
  #--------------------------------------------------------------------------
  # ● Can Damage Break Command
  #--------------------------------------------------------------------------  
  def can_damage_break_command?
      return false if BattleManager.actor == nil
      return false if BattleManager.actor != self
      return true if BattleManager.actor.restriction > 0
      return true if BattleManager.actor.dead?
      return true if BattleManager.actor.hp == 0
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Turn Clear
  #--------------------------------------------------------------------------  
  def turn_clear
      self.atb_clear 
      self.atb_escape = false 
      self.clear_actions
      self.next_turn = false
      $game_temp.remove_order(self)
  end  
  
  #--------------------------------------------------------------------------
  # ● Effect for Dead
  #--------------------------------------------------------------------------  
  def effect_for_dead      
      atb_initial
      $game_temp.refresh_target_windows[0] = true if self.is_a?(Game_Actor)
      $game_temp.refresh_target_windows[1] = true if self.is_a?(Game_Enemy)
      if $imported[:mog_battle_cursor]
         $game_temp.battle_cursor_need_refresh[0] = true if self.is_a?(Game_Actor)
         $game_temp.battle_cursor_need_refresh[1] = true if self.is_a?(Game_Enemy)
      end         
  end
  
  #--------------------------------------------------------------------------
  # ● Remove State Auto
  #--------------------------------------------------------------------------  
  alias mog_atb_remove_states_auto remove_states_auto
  def remove_states_auto(timing)
      if SceneManager.scene_is?(Scene_Battle)
         remove_states_auto_atb(timing) ; return
      end
      mog_atb_remove_states_auto(timing)
  end  

  #--------------------------------------------------------------------------
  # ● Remove State Auto ATB
  #--------------------------------------------------------------------------  
  def remove_states_auto_atb(timing)
      states.each do |state|
      if @state_turns[state.id] == 0 
         if restriction == 4 ; remove_state(state.id) ; return ; end
            unless state.auto_removal_timing == 2 and state.max_turns <= 1
            remove_state(state.id)
            end
         end 
      end
  end  

  #--------------------------------------------------------------------------
  # ● Remove State Turn End
  #--------------------------------------------------------------------------  
  def remove_state_turn_end
      states.each do |state|
         next if state.auto_removal_timing != 2
         next if state.max_turns > 1
         remove_state(state.id)
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Die
  #--------------------------------------------------------------------------  
  alias mog_atb_die die
  def die
      mog_atb_die
      self.turn_clear ; self.atb_turn_duration = 0
  end
  
  #--------------------------------------------------------------------------
  # ● Revive
  #--------------------------------------------------------------------------  
  alias mog_atb_revive revive
  def revive
      mog_atb_revive
      self.turn_clear ; per = 25 * self.atb_max / 100 ; self.atb = rand(per)
      self.atb_turn_duration = 0
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Battle Action
  #--------------------------------------------------------------------------
  alias mog_atb_make_actions make_actions
  def make_actions
      return if !self.atb_cast.empty?
      item = self.current_action.item rescue nil
      return if item != nil
      mog_atb_make_actions
  end  
  
end

#==============================================================================
# ■ Game Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # ● Tranform
  #--------------------------------------------------------------------------  
   alias mog_at_system_transform transform
   def transform(enemy_id)
       mog_at_system_transform(enemy_id)
       self.atb_clear
   end
     
end
 
#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  
  #--------------------------------------------------------------------------
  # ● Start Command Input
  #--------------------------------------------------------------------------
  def self.input_start
      @phase = :input if @phase != :input
      return !@surprise && $game_party.inputable?
  end
  
  #--------------------------------------------------------------------------
  # ● Battle Start
  #--------------------------------------------------------------------------  
  def self.battle_start
      $game_system.battle_count += 1
      $game_party.on_battle_start
      $game_troop.on_battle_start
      atb_initial_setup ; @turn_duration = set_turn_duration
      if MOG_ATB_SYSTEM::MESSAGE_ENEMY_APPEAR
         $game_troop.enemy_names.each do |name|
         $game_message.add(sprintf(Vocab::Emerge, name))
         end
      end
      if @preemptive
         $game_message.add(sprintf(Vocab::Preemptive, $game_party.name))
      elsif @surprise
         $game_message.add(sprintf(Vocab::Surprise, $game_party.name))
      end
      wait_for_message ; @preemptive = false ; @surprise = false
  end
  
  #--------------------------------------------------------------------------
  # ● ATB Initial Setup
  #--------------------------------------------------------------------------  
  def self.atb_initial_setup
      battlers.each do |battler|
      battler.atb_initial ; initial_atb_parameter(battler)
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Initial ATB Parameter
  #--------------------------------------------------------------------------  
  def self.initial_atb_parameter(battler)
      @at_phase = 0
      nt = battler.atb_max * 30 / 100
      st = battler.atb_max * 20 / 100      
      pt = battler.atb_max * 65 / 100
      n_at = rand(nt) ; p_at = pt + rand(nt) ; s_at = rand(st)        
      if BattleManager.preemptive_attack
         battler.atb = p_at if battler.is_a?(Game_Actor)
         battler.atb = s_at if battler.is_a?(Game_Enemy)
      elsif BattleManager.surprise_attack   
         battler.atb = p_at if battler.is_a?(Game_Enemy)
         battler.atb = s_at if battler.is_a?(Game_Actor)
      else   
         battler.atb = n_at
      end
      battler.atb = battler.atb_max - 1  if battler.atb >= battler.atb_max
      battler.turn_clear if battler.dead? or battler.restriction == 4
  end
  
  #--------------------------------------------------------------------------
  # ● Set Turn Duration
  #--------------------------------------------------------------------------  
  def self.set_turn_duration
      max_battlers = battlers.size > 0 ? battlers.size : 1      
      case MOG_ATB_SYSTEM::TURN_DURATION_TYPE
        when 1 ; n  = $game_system.atb_turn_duration[1] * max_battlers          
        when 2
           turn_sp = 0
           battlers.each do |battler| turn_sp += battler.agi ; end  
           n = $game_system.atb_turn_duration[1] + (turn_sp / max_battlers) 
        else ; n = $game_system.atb_turn_duration[1]
      end
      n2 = [[n, 9999].min, 120].max     
      battlers.each do |battler| 
          perc = 30 * n2 / 100
          battler.atb_turn_duration = rand(perc)      
      end  
      return n2
  end
  
  #--------------------------------------------------------------------------
  # ● Force Clear Battler ATB
  #--------------------------------------------------------------------------  
  def self.force_clear_battler_atb
      battlers.each do |battler| 
      battler.turn_clear if battler.dead? or battler.restriction == 4
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Turn Start
  #--------------------------------------------------------------------------
  def self.turn_start    
      @phase = :turn ; clear_actor
  end  
  
  #--------------------------------------------------------------------------
  # ● Preemtive Attack
  #--------------------------------------------------------------------------  
  def self.preemptive_attack
      @preemptive
  end  
  
  #--------------------------------------------------------------------------
  # ● Suprise Attack
  #--------------------------------------------------------------------------    
  def self.surprise_attack
      @surprise
  end

  #--------------------------------------------------------------------------
  # ● Battlers
  #--------------------------------------------------------------------------    
  def self.battlers
      return $game_troop.members + $game_party.battle_members
  end  
  
  #--------------------------------------------------------------------------
  # ● Update ATB
  #--------------------------------------------------------------------------    
  def update_atb?
      return false if @atb_in_turn
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Update ATB
  #--------------------------------------------------------------------------    
  def self.update_atb
      return if $game_temp.atb_wait
      return if $game_temp.end_phase_duration[1] > 0
      return if $game_temp.battle_end       
      return if $game_temp.atb_frame_skip > 0
      return @current_battler if @current_battler
      for battler in battlers
          next if !battler_update?(battler)
          battler.atb_update
          update_battler_turn(battler)
          @current_battler = set_current_battler(battler)
          break if $game_temp.atb_frame_skip > 0
      end
      return nil
  end
  
  #--------------------------------------------------------------------------
  # ● Battler Update?
  #--------------------------------------------------------------------------    
  def self.battler_update?(battler)
      return false if battler.dead? or battler.hp == 0
      return true
  end
 
  #--------------------------------------------------------------------------
  # ● Update Battler Turn
  #--------------------------------------------------------------------------    
  def self.update_battler_turn(battler) 
      return if @turn_duration == nil
      battler.atb_turn_duration += 1
      return if battler.atb_turn_duration < @turn_duration
      battler.atb_turn_duration = 0
      old_battler = battler
      battler.on_turn_end
      @refresh_status = true
  end
  
  #--------------------------------------------------------------------------
  # ● Set Current Battler
  #--------------------------------------------------------------------------    
  def self.set_current_battler(battler)
      return @current_battler if @current_battler
      return nil if !battler.atb_max?
      if battler.next_turn 
         battler.remove_state_turn_end            
         $game_temp.remove_order(battler)
         return battler
      end
      if battler.is_a?(Game_Actor)
        if BattleManager.actor == nil          
            if $game_temp.actor_process_event != nil
               enable_actor_command?($game_temp.actor_process_event)
               prepare_actor_command($game_temp.actor_process_event)       
               $game_temp.actor_process_event = nil
            elsif $game_temp.atb_actor_order[0] != nil and
                enable_actor_command?($game_temp.atb_actor_order[0])
                prepare_actor_command($game_temp.atb_actor_order[0])
            else
                prepare_actor_command(battler) if enable_actor_command?(battler)
                if battler_confusion?(battler)                  
                   battler.make_actions
                   battler.next_turn = true if !can_execute_cast_action?(battler)
                end       
             end
         else      
             if battler_confusion?(battler)                  
                battler.make_actions
                battler.next_turn = true if !can_execute_cast_action?(battler)
             end
         end 
     else
         battler.make_actions
         battler.next_turn = true if !can_execute_cast_action?(battler)
      end   
      return nil
  end
  
  #--------------------------------------------------------------------------
  # ●  Enable Actor Command
  #--------------------------------------------------------------------------    
  def self.battler_confusion?(battler)
      return false if battler.hp == 0 or battler.dead?
      return true if battler.confusion?
      return false
  end
  
  #--------------------------------------------------------------------------
  # ●  Enable Actor Command
  #--------------------------------------------------------------------------    
  def self.enable_actor_command?(battler)
      return false if @command_actor != nil
      return false if battler.dead?
      return false if battler.restriction != 0
      return true
  end  
      
  #--------------------------------------------------------------------------
  # ● Prepare Actor Command
  #--------------------------------------------------------------------------    
  def self.prepare_actor_command(battler)
      battler.remove_state_turn_end      
      @command_actor = battler ; @command_selection = true
      $game_temp.remove_order(battler)      
  end
  
  #--------------------------------------------------------------------------
  # ● Can Execute Cast Action?
  #--------------------------------------------------------------------------    
  def self.can_execute_cast_action?(battler)
      item = battler.current_action.item rescue nil  
      return false if item == nil
      if item.speed != 0 and battler.atb_cast.empty?
         battler.atb_cast = [item,item.speed.abs,0] 
         battler.animation_id = MOG_ATB_SYSTEM::CAST_ANIMATION
         battler.atb = 0
         return true
      end    
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Actor in turn
  #--------------------------------------------------------------------------    
  def self.actor_command?
      return false if !@command_selection 
      return false if @command_actor == nil
      if @command_actor.restriction != 0
         @command_selection = false
         return false 
      end   
      @command_selection = false      
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Current Battler Clear
  #--------------------------------------------------------------------------    
  def self.current_battler_clear(subject)
      return if subject == nil 
      return if @current_battler == nil
      return if @current_battler != subject
      @current_battler.atb_clear 
      @current_battler.atb_escape = false
      @current_battler.clear_actions 
      @current_battler.next_turn = false
      @current_battler = nil
  end  
  
  #--------------------------------------------------------------------------
  # ● Command Selection Clear
  #--------------------------------------------------------------------------    
  def self.command_selection_clear
      $game_temp.remove_order(@command_actor)
      @command_selection = false ; @command_actor = nil 
      $game_temp.actor_command_index = 0
  end
  
  #--------------------------------------------------------------------------
  # ● Command Selection
  #--------------------------------------------------------------------------    
  def self.command_selection?
      @command_selection
  end
  
  #--------------------------------------------------------------------------
  # ● Command Selection need clear?
  #--------------------------------------------------------------------------    
  def self.command_need_clear?
      return true if @command_actor == nil and @command_selection
      return false
  end
    
  #--------------------------------------------------------------------------
  # ● Next Command
  #--------------------------------------------------------------------------    
  def self.next_command
      if @command_actor ; @command_actor.make_actions ; return true ;end
      return false
  end  
  
  #--------------------------------------------------------------------------
  # ● Command End
  #--------------------------------------------------------------------------    
  def self.command_end
      $game_temp.remove_order(@command_actor)
      @command_selection = false
      $game_temp.actor_command_index = 0
      command_end_actor if @command_actor
      @command_actor = nil
  end

  #--------------------------------------------------------------------------
  # ● Command End Actor
  #--------------------------------------------------------------------------    
  def self.command_end_actor
      item = @command_actor.current_action.item rescue nil  
      set_cast_action(item) if set_cast_action?(item)
      @command_actor.next_turn = true if @command_actor != nil
      @current_battler = @command_actor if @current_battler == nil
      $game_temp.actor_process_event = nil
  end
      
  #--------------------------------------------------------------------------
  # ● Set Cast Action?
  #--------------------------------------------------------------------------    
  def self.set_cast_action?(item)
      if item.is_a?(RPG::Skill)
         return false if @command_actor.guard_skill_id == item.id
      end
      return false if item.nil?
      return false if item.speed == 0
      return false if !@command_actor.atb_cast.empty?
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Set Cast Action
  #--------------------------------------------------------------------------    
  def self.set_cast_action(item)
      if item.speed.abs > 10
         @command_actor.atb_cast = [item,item.speed.abs,0]
      else   
         @command_actor.atb_cast = [item,10,10]
      end  
      @command_actor.animation_id = MOG_ATB_SYSTEM::CAST_ANIMATION
      @command_actor.atb = 0 ; @command_actor.next_turn = false
      @command_actor = nil
  end       
    
  #--------------------------------------------------------------------------
  # ● End Turn
  #--------------------------------------------------------------------------
  def self.in_turn?
      return $game_temp.atb_in_turn
  end  

  #--------------------------------------------------------------------------
  # ● Set Refresh Status
  #--------------------------------------------------------------------------
  def self.set_refresh_status(value)
      @refresh_status = value
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh Status
  #--------------------------------------------------------------------------
  def self.refresh_status?
      @refresh_status
  end
  
  #--------------------------------------------------------------------------
  # ● Actor
  #--------------------------------------------------------------------------
  def self.actor
      @command_actor
  end

  #--------------------------------------------------------------------------
  # ● Cancel Actor Command
  #--------------------------------------------------------------------------
  def self.cancel_actor_command(minus = false)
      @command_selection = false
      return if @command_actor == nil
      @command_actor.atb = (@command_actor.atb * 80 / 100).truncate if minus 
      @command_actor = nil
      $game_temp.actor_command_index = 0
  end
  
  #--------------------------------------------------------------------------
  # ● Battler
  #--------------------------------------------------------------------------
  def self.set_battler_in_turn(battler)
      @battler_in_turn = battler
  end
  
  #--------------------------------------------------------------------------
  # ● Battler in turn?
  #--------------------------------------------------------------------------
  def self.battler_in_turn?(battler)
      return true if @battler_in_turn == battler
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Turn Start ABS
  #--------------------------------------------------------------------------
  def self.turn_start_abs
      @phase = :turn        
  end
    
  #--------------------------------------------------------------------------
  # ● Set Subject
  #--------------------------------------------------------------------------
  def self.set_subject(subject)
      @subject = subject
  end

  #--------------------------------------------------------------------------
  # ● Subject
  #--------------------------------------------------------------------------
  def self.subject
      @subject
  end  
  
end  

#==============================================================================
# ■ BattleManager
#==============================================================================
class << BattleManager
  
  #--------------------------------------------------------------------------
  # ● Init Members
  #--------------------------------------------------------------------------
  alias mog_atb_init_members init_members
  def init_members
      mog_atb_init_members
      set_init_atb_data
  end
  
  #--------------------------------------------------------------------------
  # ● Set Init ATB Data
  #--------------------------------------------------------------------------
  def set_init_atb_data
      @current_battler = nil ; @actor_in_turn = nil ; @command_selection = nil
      @atb_target_index = nil ; @command_actor = nil ; $game_temp.atb_user = nil
      $game_temp.turn_duration_clear = false ; $game_temp.battle_end = false
      $game_temp.atb_in_turn = true ; $game_temp.atb_wait = false 
      @turn_duration = set_turn_duration ; @refresh_status = false 
      $game_temp.atb_frame_skip = 30 ; @battler_in_turn = nil
      $game_temp.refresh_target_windows = [false,false]
      $game_temp.refresh_actor_command = false ; @subject = nil
      $game_temp.refresh_battle_atb = false ; $game_temp.atb_break_duration = 0
      $game_temp.end_phase_duration = [false,0] ; $game_temp.battle_end2 = false     
      $game_temp.actor_command_index = 0 ; $game_temp.refresh_item_window = false
      $game_system.atb_turn_duration[0] = 0 ; $game_temp.atb_stop = [false,false]
      $game_temp.atb_actor_order = [] ; $game_temp.break_command = false
      $game_temp.actor_process_event = nil ; $game_temp.hwindow_atb = false
  end
  
  #--------------------------------------------------------------------------
  # ● Determine Win/Loss Results
  #--------------------------------------------------------------------------
  alias mog_atb_judge_win_loss judge_win_loss
  def judge_win_loss
      return if $game_temp.end_phase_duration[0]
      return if $game_troop.interpreter.running?
      mog_atb_judge_win_loss
  end
  
  #--------------------------------------------------------------------------
  # ● Clear Base Parameter
  #--------------------------------------------------------------------------    
  def clear_base_parameter
      battlers.each do |battler| battler.atb_initial end
  end
  
  #--------------------------------------------------------------------------
  # ● Process Abort
  #--------------------------------------------------------------------------    
  alias mog_atb_process_abort process_abort  
  def process_abort  
      $game_temp.atb_wait = true ; $game_temp.battle_end = true
      clear_base_parameter
      mog_atb_process_abort      
  end
  
  #--------------------------------------------------------------------------
  # ● Process Defeat
  #--------------------------------------------------------------------------    
  alias mog_atb_process_defeat process_defeat
  def process_defeat
      clear_base_parameter
      $game_temp.atb_wait = true ; $game_temp.battle_end = true    
      mog_atb_process_defeat
  end  
 
  #--------------------------------------------------------------------------
  # ● Process Victory
  #--------------------------------------------------------------------------    
  alias mog_atb_process_victory process_victory
  def process_victory 
      $game_temp.atb_wait = true ; $game_temp.battle_end = true
      mog_atb_process_victory
  end 

  #--------------------------------------------------------------------------
  # ● Prior Command
  #--------------------------------------------------------------------------    
  alias mog_atb_prior_command prior_command
  def prior_command
      if $sv_camera != nil
         actor = $game_party.battle_members[@actor_index] rescue nil
         return if actor == nil
      end
      mog_atb_prior_command
  end    
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  include MOG_ATB_SYSTEM
  
  #--------------------------------------------------------------------------
  # ● Battle Start
  #--------------------------------------------------------------------------
  def battle_start
      BattleManager.battle_start
      process_event
      set_turn_duration
  end   
  
  #--------------------------------------------------------------------------
  # ● Set Turn Duration
  #--------------------------------------------------------------------------
  def set_turn_duration
      $game_system.atb_turn_duration = [0,BattleManager.set_turn_duration]
      @status_window.open if @status_window != nil
      BattleManager.turn_start_abs
  end     
  
  #--------------------------------------------------------------------------
  # ● Next Command
  #--------------------------------------------------------------------------  
  alias mog_atb_next_command next_command
  def next_command
      BattleManager.command_selection_clear if BattleManager.command_selection_clear?
      mog_atb_next_command
  end    
  
  #--------------------------------------------------------------------------
  # ● Process Action
  #--------------------------------------------------------------------------  
  def process_action
      process_atb_type
      return if !process_action_atb?
      update_turn if update_turn?
      @subject = BattleManager.update_atb
      process_actor_command if BattleManager.actor_command?
      force_refresh_status if BattleManager.refresh_status?
      process_action_atb if @subject
  end  

  #--------------------------------------------------------------------------
  # ● Update Break Phase
  #--------------------------------------------------------------------------  
  def update_break_phase
      $game_temp.atb_break_duration += 1
      return if $game_temp.atb_break_duration < 30
      $game_temp.atb_break_duration = 0
      process_atb_break if proccess_atb_break?
  end
  
  #--------------------------------------------------------------------------
  # ● Process ATB Break
  #--------------------------------------------------------------------------  
  def process_atb_break      
      if BattleManager.actor != nil 
         BattleManager.actor.atb -= 1
         if BattleManager.actor.restriction == 4 or BattleManager.actor.hp == 0 or
            BattleManager.actor.dead?
            BattleManager.actor.turn_clear
         end
      end
      hide_base_window
      BattleManager.command_selection_clear
  end
  
  #--------------------------------------------------------------------------
  # ● Process Action
  #--------------------------------------------------------------------------  
  def proccess_atb_break?
      return false if $game_troop.interpreter.running?
      members_atb_max = true
      members_next_turn = true
      for battler in $game_party.battle_members
          members_atb_max = false if !battler.atb_max?
          members_next_turn = false if !battler.next_turn          
      end
      if BattleManager.actor != nil 
         return true if can_break_actor_command?
       else
         return true if members_atb_max and !members_next_turn
      end
      return false 
  end

  #--------------------------------------------------------------------------
  # ● Can Break Actor Command
  #--------------------------------------------------------------------------  
  def can_break_actor_command?
      return true if BattleManager.actor.next_turn 
      return true if BattleManager.actor.restriction > 0
      return true if BattleManager.actor.dead? or BattleManager.actor.hp == 0
      return true if !base_window_active?
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Base Window Active
  #--------------------------------------------------------------------------  
  def base_window_active?
      return true if @actor_window.active
      return true if @enemy_window.active
      return true if @item_window.active
      return true if @skill_window.active
      return true if @party_command_window.active
      return true if @actor_command_window.active
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Process Action
  #--------------------------------------------------------------------------  
  def process_action_atb
      $game_temp.remove_order(@subject)
      loop do
          if @subject == nil
             turn_end_subject_nil
             break
          end   
          BattleManager.set_battler_in_turn(@subject)
          BattleManager.set_subject(@subject)
          @log_window.clear
          if @subject.atb_escape 
             process_escape 
             break
          end
          process_before_execute_action
          process_execute_action if @subject.current_action
          process_after_execute_action
          hide_windows_for_dead
          if break_process_action_atb?
             process_action_end 
             turn_end 
             break
          end  
      end
  end

  #--------------------------------------------------------------------------
  # ● Break Process Action Atb
  #--------------------------------------------------------------------------   
  def break_process_action_atb?
      return true if !@subject.current_action
      return true if @subject.restriction == 4
      return true if @subject.dead? or @subject.hp == 0
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Can Break Process Action?
  #--------------------------------------------------------------------------  
  def can_break_process_action?
      return true if @subject == nil
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Can Break Command?
  #--------------------------------------------------------------------------    
  def can_break_command?
      return false if BattleManager.actor == nil
      return true if BattleManager.actor.hp == 0
      return true if BattleManager.actor.dead?
      return true if BattleManager.actor.restriction != 0
      return false
  end

  #--------------------------------------------------------------------------
  # ● Can Break Command2
  #--------------------------------------------------------------------------    
  def can_break_command2?
      return false if BattleManager.actor != nil
      return true if BattleManager.command_selection?
      return false
  end  
  
  #--------------------------------------------------------------------------
  # ● Break Command
  #--------------------------------------------------------------------------    
  def break_command
      $game_temp.break_command = false
      BattleManager.actor.turn_clear if BattleManager.actor != nil
      hide_base_window
      BattleManager.command_selection_clear
  end      

  #--------------------------------------------------------------------------
  # ● Turn End Subject Nil
  #--------------------------------------------------------------------------   
  def turn_end_subject_nil
      refresh_status
      BattleManager.judge_win_loss
      @subject =  nil
      BattleManager.set_subject(@subject)
      @log_window.wait
      @log_window.clear
      $game_temp.atb_break_duration = 100
      execute_event_phase if execute_event_phase_turn?
  end    
  
  #--------------------------------------------------------------------------
  # ● Process Escape
  #--------------------------------------------------------------------------  
  def process_escape
      if BattleManager.process_escape     
         process_execute_escape 
      else   
         start_actor_command_selection if BattleManager.actor
         @status_window.open
      end  
      turn_end    
  end
       
  #--------------------------------------------------------------------------
  # ● Process Actor Command
  #--------------------------------------------------------------------------  
  def process_actor_command
      start_actor_command_selection
  end
  
  #--------------------------------------------------------------------------
  # ● Process Before Execute Action
  #--------------------------------------------------------------------------  
  def process_before_execute_action    
  end  
  
  #--------------------------------------------------------------------------
  # ● Process After Execute Action
  #--------------------------------------------------------------------------  
  def process_after_execute_action    
  end    
  
  #--------------------------------------------------------------------------
  # ● Refresh Actor Command
  #--------------------------------------------------------------------------  
  def refresh_actor_command?
      return false if !$game_temp.refresh_actor_command
      return false if !@actor_command_window.active
      return false if !BattleManager.actor
      return true
  end  

  #--------------------------------------------------------------------------
  # ● Update Actor Command
  #--------------------------------------------------------------------------  
  def update_actor_command
      return if !@actor_command_window.active
      return if !BattleManager.actor
      if ENABLE_BUTTON_NEXT_ACTOR
         if Input.trigger?(BUTTON_NEXT_ACTOR_LEFT) ; turn_to_next_actor(-1) rescue nil
         elsif Input.trigger?(BUTTON_NEXT_ACTOR_RIGHT) ; turn_to_next_actor(1) rescue nil
         end  
      end   
  end  

  #--------------------------------------------------------------------------
  # ● Turn To Next Actor
  #--------------------------------------------------------------------------  
  def turn_to_next_actor(value)
      return if BattleManager.actor == nil
      next_index = BattleManager.actor.index + value
      next_index = 0 if next_index >= $game_party.battle_members.size
      battler = $game_party.battle_members[next_index]
      next_act = false
      if battler.movable_atb? 
         cancel_actor_command_scene(false) ; BattleManager.prepare_actor_command(battler)
         process_actor_command if BattleManager.actor_command?
         next_act = true
      else           
        @tnext_index = value   
         for battler in $game_party.battle_members
             next_index += @tnext_index
             if next_index >= $game_party.battle_members.size
                next_index = 0 ; @tnext_index = 1
                if next_actor_command?(next_index) ; next_act = true ; break ; end
             elsif next_index < 0
                next_index = $game_party.battle_members.size ;  @tnext_index = -1 
                if next_actor_command?(next_index) ; next_act = true ; break ; end
             end
             if next_actor_command?(next_index) ; next_act = true ; break ; end
         end  
      end
     Sound.play_cancel if !next_act
  end
         
  #--------------------------------------------------------------------------
  # ● Next Actor Command?
  #--------------------------------------------------------------------------  
  def next_actor_command?(next_index)
      for battler in $game_party.battle_members
          next if next_index == BattleManager.actor.index
          if next_index == battler.index and battler.movable_atb? 
             cancel_actor_command_scene(false)
             BattleManager.prepare_actor_command(battler)
             process_actor_command if BattleManager.actor_command?
             return true
          end            
      end
      return false
  end  
         
  #--------------------------------------------------------------------------
  # ● Cancel Actor Command scene
  #--------------------------------------------------------------------------  
  def cancel_actor_command_scene(atb_cost = false)
      @actor_command_window.close ; @actor_command_window.hide_all
      BattleManager.cancel_actor_command(atb_cost)
  end
  
  #--------------------------------------------------------------------------
  # ● Update Party Command
  #--------------------------------------------------------------------------      
  def update_party_command
      return if !@party_command_window.active
      return if !BattleManager.actor
      if Input.trigger?(:B)
         Sound.play_cancel
         @party_command_window.deactivate ; start_actor_command_selection
      end  
  end
  
  #--------------------------------------------------------------------------
  # ● Create All Windows
  #--------------------------------------------------------------------------      
  alias mog_atb_create_all_windows create_all_windows
  def create_all_windows
      mog_atb_create_all_windows
      @pre_viewport_visible = true
      @info_xy = [0,(Graphics.width - @status_window.width) / 2, Graphics.width - @status_window.width ]
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Info Viewport
  #--------------------------------------------------------------------------      
  def update_info_viewport
      if center_viewport?
         move_info_viewport(@info_xy[1]) ; return 
      end
      if @party_command_window.active ; move_info_viewport(@info_xy[0])   
      elsif BattleManager.actor ; move_info_viewport(@info_xy[2])
      else ; move_info_viewport(@info_xy[1])
      end  
  end  

  #--------------------------------------------------------------------------
  # ● Update Info Viewport
  #--------------------------------------------------------------------------      
  def center_viewport?
      return true if $game_message.visible
      return true if BattleManager.actor == nil
      return true if $game_temp.battle_end
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Process Action ATB
  #--------------------------------------------------------------------------  
  def process_action_atb?  
      return false if $game_troop.interpreter.running?
      return false if $game_temp.end_phase_duration[1] > 0  
      return false if $game_temp.atb_wait
      return false if $game_temp.battle_end
      return false if $game_temp.battle_end2
      return false if scene_changing? 
      return false if !$game_temp.sprite_visible
      return false if $game_temp.atb_stop[1]
      return false if @combatlog_window.visible if @combatlog_window != nil
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Process ATB Type
  #--------------------------------------------------------------------------  
  def process_atb_type
      $game_temp.atb_frame_skip -= 1 if $game_temp.atb_frame_skip > 0
      return if $game_temp.battle_end
      return if $game_temp.end_phase_duration[1] > 0
      case $game_system.atb_type
           when 0 ; $game_temp.atb_wait = set_atb_type_wait
           when 1 ; $game_temp.atb_wait = set_atb_type_semi_wait
           else ; $game_temp.atb_wait = false
      end
  end
      
  #--------------------------------------------------------------------------
  # ● Set Atb Type Wait
  #--------------------------------------------------------------------------  
  def set_atb_type_wait
      return true if @actor_window.active
      return true if @enemy_window.active
      return true if @item_window.active
      return true if @skill_window.active
      return true if @party_command_window.active
      return true if @actor_command_window.active
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Set Atb Type Semi Wait
  #--------------------------------------------------------------------------  
  def set_atb_type_semi_wait
      return true if @item_window.active
      return true if @skill_window.active
      return false    
  end
  
  #--------------------------------------------------------------------------
  # ● Process Execute Escape
  #--------------------------------------------------------------------------  
  def process_execute_escape
      $game_temp.battle_end = true 
      hide_base_window
      $game_temp.atb_user = nil
      $game_temp.battle_cursor[2] = false if $imported[:mog_battle_cursor] 
      BattleManager.command_selection_clear 
  end
  
  #--------------------------------------------------------------------------
  # ● Battle End?
  #--------------------------------------------------------------------------  
  def battle_end?
      return true if $game_party.members.empty?
      return true if $game_party.all_dead?
      return true if $game_troop.all_dead?
      return true if $game_temp.battle_end
      return false
  end
    
  #--------------------------------------------------------------------------
  # ● Command Escape
  #--------------------------------------------------------------------------  
  def command_escape
      BattleManager.actor.atb_escape = true if BattleManager.actor
      BattleManager.command_end
      @party_command_window.close
      hide_base_window
  end  
  
  #--------------------------------------------------------------------------
  # ● Command Escape2
  #--------------------------------------------------------------------------  
  def command_escape2
     turn_start unless BattleManager.process_escape
  end
   
  #--------------------------------------------------------------------------
  # ● Execute Action
  #--------------------------------------------------------------------------  
  alias mog_atb_execute_action execute_action
  def execute_action
      @cp_members = []
      return if battle_end? or @subject == nil
      @cp_members = current_cp_members if can_execute_cooperation_skill?            
      mog_atb_execute_action
  end
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------  
  alias mog_atb_use_item use_item
  def use_item
      return if battle_end? or @subject == nil
      mog_atb_use_item
  end
  
  #--------------------------------------------------------------------------
  # ● Show Animation
  #--------------------------------------------------------------------------  
  alias mog_atb_event_show_animation show_animation
  def show_animation(targets, animation_id)
      execute_event_phase if execute_event_phase_turn?
      mog_atb_event_show_animation(targets, animation_id)    
  end
  
  #--------------------------------------------------------------------------
  # ● Force Refresh Status
  #--------------------------------------------------------------------------  
  def force_refresh_status
      BattleManager.set_refresh_status(false)
      refresh_status
  end

  #--------------------------------------------------------------------------
  # ● Refresh Battle ATB
  #--------------------------------------------------------------------------  
  def refresh_battle_atb
      $game_temp.refresh_battle_atb = false
      hide_base_window
      battle_start      
  end

  #--------------------------------------------------------------------------
  # ● Hide Base Window
  #--------------------------------------------------------------------------  
  def hide_base_window(target_window = true,actor_window = false)
      @actor_window.hide
      @actor_window.active = false
      @enemy_window.hide
      @enemy_window.active = false
      @help_window.hide
      @party_command_window.deactivate
      @party_command_window.close
      @status_window.unselect
      instance_variables.each do |varname|
         ivar = instance_variable_get(varname)
         if ivar.is_a?(Window) 
            next if !need_hide_window?(ivar,actor_window)            
            ivar.hide_all
         end   
      end
      @pre_viewport_visible = @info_viewport.visible
      @info_viewport.visible = true ; @status_window.show
      @status_aid_window.hide_all if @status_aid_window != nil
  end

  #--------------------------------------------------------------------------
  # ● Need Hide Window?
  #--------------------------------------------------------------------------  
  def need_hide_window?(ivar,actor_window)
      return false if ivar.is_a?(Window_Message)
      return false if ivar.is_a?(Window_BattleActor)
      return false if ivar.is_a?(Window_BattleEnemy)
      return false if ivar.is_a?(Window_BattleStatus)
      return false if ivar.is_a?(Window_PartyCommand)
      return false if ivar.is_a?(Window_ActorCommand) and actor_window
      if $imported["YEA-VictoryAftermath"]
         return false if ivar.is_a?(Window_VictoryTitle)
         return false if ivar.is_a?(Window_VictoryEXP_Back)
         return false if ivar.is_a?(Window_VictoryEXP_Front)
         return false if ivar.is_a?(Window_VictoryLevelUp)
         return false if ivar.is_a?(Window_VictorySkills)
         return false if ivar.is_a?(Window_VictorySpoils)
      end      
      return true
  end     
  
  #--------------------------------------------------------------------------
  # ● Record Window Data
  #--------------------------------------------------------------------------  
  def record_window_data(target_window = true)
      return if $game_temp.hwindow_atb
      $game_temp.hwindow_atb = true
      @pre_battler = BattleManager.actor
      @battler_in_turn_temp = @actor_command_window.active
      instance_variables.each do |varname|
         ivar = instance_variable_get(varname)
         ivar.record_data if ivar.is_a?(Window)
      end      
      if $imported[:mog_battle_cursor]
         @battle_cursor_visible = $game_temp.battle_cursor[2]
         $game_temp.battle_cursor[2] = false
      end         
      hide_base_window(target_window)    
  end
    
  #--------------------------------------------------------------------------
  # ● Fade Base Window
  #--------------------------------------------------------------------------  
  def fade_base_window(fade_value)
      instance_variables.each do |varname|
         ivar = instance_variable_get(varname)
         if ivar.is_a?(Window)
            next if !need_fade_after_battle?(ivar)
            ivar.opacity -= fade_value
            ivar.contents_opacity -= fade_value
         end
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Need Fade After Battle?
  #--------------------------------------------------------------------------  
  def need_fade_after_battle?(ivar)
      return false if ivar.is_a?(Window_Message)
      if $imported["YEA-VictoryAftermath"]
         return false if ivar.is_a?(Window_VictoryTitle)
         return false if ivar.is_a?(Window_VictoryEXP_Back)
         return false if ivar.is_a?(Window_VictoryEXP_Front)
         return false if ivar.is_a?(Window_VictoryLevelUp)
         return false if ivar.is_a?(Window_VictorySkills)
         return false if ivar.is_a?(Window_VictorySpoils)
      end
      return true
  end    
 
  #--------------------------------------------------------------------------
  # ● Record Window Data
  #--------------------------------------------------------------------------  
  def restore_window_data
      return if battle_end?
       if @pre_battler and @pre_battler.dead?
          hide_windows_for_dead
       else
          instance_variables.each do |varname|
             ivar = instance_variable_get(varname)
             ivar.restore_data if ivar.is_a?(Window) 
          end   
          @info_viewport.visible = @pre_viewport_visible
          @actor_command_window.open if @actor_command_window.visible
          @status_window.open if @status_window.visible
          @actor_window.show if @actor_window.active
          @actor_window.restore_data if @actor_window.active
          @enemy_window.show if @enemy_window.active
          @enemy_window.restore_data if @enemy_window.active
          start_actor_command_selection(false) if @actor_command_window.active
          start_party_command_selection if @party_command_window.active
          if $imported[:mog_battle_cursor]
             $game_temp.battle_cursor[2] = @battle_cursor_visible
          end
      end
      $game_temp.hwindow_atb = false
  end
    
  #--------------------------------------------------------------------------
  # ● Hide Windows for dead
  #--------------------------------------------------------------------------  
  def hide_windows_for_dead
      return if BattleManager.actor == nil
      return if !BattleManager.actor.dead?
      hide_base_window
      $game_temp.atb_user = nil
      $game_temp.battle_cursor[2] = false if $imported[:mog_battle_cursor] 
      BattleManager.command_selection_clear
  end

  #--------------------------------------------------------------------------
  # ● Update Target Windows
  #--------------------------------------------------------------------------  
  def update_target_windows
      if @actor_window.active and $game_temp.refresh_target_windows[0]
         @actor_window.refresh
         @actor_window.update
         $game_temp.refresh_target_windows[0] = false
      end  
      if @enemy_window.active and $game_temp.refresh_target_windows[1]
         @enemy_window.refresh
         @enemy_window.cursor_left if @enemy_window.enemy == nil
         @enemy_window.update
         $game_temp.refresh_target_windows[1] = false
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Process Execute Action
  #--------------------------------------------------------------------------  
  def process_execute_action
      @subject.current_action.prepare
      if @subject.current_action.valid?       
         @status_window.open ; execute_action
      end
      process_before_remove_action 
      @subject.remove_current_action
  end 
 
  #--------------------------------------------------------------------------
  # ● Process Before Remove Action
  #--------------------------------------------------------------------------  
  def process_before_remove_action    
  end
  
  #--------------------------------------------------------------------------
  # * End Turn
  #--------------------------------------------------------------------------
  def turn_end
      BattleManager.set_battler_in_turn(nil)   
      all_battle_members.each do |battler|
          refresh_status
          @log_window.wait_and_clear
      end
      turn_reset
  end  
  
  #--------------------------------------------------------------------------
  # ● Turn Reset
  #--------------------------------------------------------------------------
  def turn_reset
      $game_temp.remove_order(@subject)      
      BattleManager.current_battler_clear(@subject)
      BattleManager.command_selection_clear if BattleManager.command_need_clear?
      @subject =  nil
      BattleManager.set_subject(@subject)
      @log_window.wait
      @log_window.clear      
      $game_temp.atb_break_duration = 100
  end
     
  #--------------------------------------------------------------------------
  # ● Execute Event Phase Turn?
  #--------------------------------------------------------------------------
  def execute_event_phase_turn?
      return false if !$game_troop.can_interpreter_running?(false) 
      return false if $game_party.members.empty?
      return false if $game_party.all_dead?
      return false if $game_troop.all_dead?
      return true 
  end  
      
  #--------------------------------------------------------------------------
  # ● Update 
  #--------------------------------------------------------------------------             
  def update
      update_basic    
      refresh_battle_atb if $game_temp.refresh_battle_atb
      process_action if BattleManager.in_turn?
      update_end_phase if $game_temp.end_phase_duration[1] > 0
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Basic
  #--------------------------------------------------------------------------             
  alias mog_atb_update_basic update_basic
  def update_basic
      update_break_phase
      break_command if force_break_command?
      update_atb_basic if !$game_troop.interpreter.running?
      mog_atb_update_basic
  end
     
  #--------------------------------------------------------------------------
  # ● Force Break Command
  #--------------------------------------------------------------------------             
  def force_break_command?
      return true if $game_temp.break_command
      return true if can_break_command?
      return true if can_break_command2?
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Update Atb Basic
  #--------------------------------------------------------------------------             
  def update_atb_basic
      if @actor_command_window.active
         update_actor_command
      else   
         update_party_command
      end   
      update_target_windows      
      refresh_item_skill_window if need_refresh_item_skill_window?
      start_actor_command_selection if refresh_actor_command?
      fade_base_window(15) if $game_temp.battle_end
  end  
  
  #--------------------------------------------------------------------------
  # ● Need Refresh Item Skill Window?
  #--------------------------------------------------------------------------             
  def need_refresh_item_skill_window?
      return true if $game_temp.refresh_item_window
      return false
  end
    
  #--------------------------------------------------------------------------
  # ● Refresh Item Skill Window
  #--------------------------------------------------------------------------             
  def refresh_item_skill_window
      $game_temp.refresh_item_window = false
      @item_window.refresh if @item_window.visible
      @skill_window.refresh if @skill_window.visible
  end
  
  #--------------------------------------------------------------------------
  # ● Update End Phase
  #--------------------------------------------------------------------------             
  def update_end_phase
      $game_temp.end_phase_duration[1] -= 1
      return if $game_temp.end_phase_duration[1] > 0
      $game_temp.end_phase_duration[0] = false
      BattleManager.judge_win_loss
  end
  
  #--------------------------------------------------------------------------
  # ● Process Event
  #--------------------------------------------------------------------------             
  alias mog_atb_process_event process_event
  def process_event
      if battle_end? ; hide_base_window ; $game_temp.end_phase_duration = [true,30] ; end
      $game_temp.actor_process_event = BattleManager.actor
      mog_atb_process_event
      process_break_atb_event
  end
  
  #--------------------------------------------------------------------------
  # ● Process Break ATB Event
  #--------------------------------------------------------------------------             
  def process_break_atb_event
      if break_actor_command?
         BattleManager.actor.turn_clear
         BattleManager.command_selection_clear
      end
      BattleManager.force_clear_battler_atb
  end
  
  #--------------------------------------------------------------------------
  # ● Break Actor Command
  #--------------------------------------------------------------------------             
  def break_actor_command?
      return false if BattleManager.actor == nil
      return true if BattleManager.actor.dead?
      return true if BattleManager.actor.restriction != 0
      return false 
  end
  
  #--------------------------------------------------------------------------
  # * Processing at End of Action
  #--------------------------------------------------------------------------
  alias mog_atb_process_action_end process_action_end
  def process_action_end
      if battle_end? ; hide_base_window ; $game_temp.end_phase_duration = [true,30] ; end
      mog_atb_process_action_end
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Turn
  #--------------------------------------------------------------------------             
  def update_turn
      force_reset_turn_duration if $game_temp.turn_duration_clear
      $game_system.atb_turn_duration[0] += 1 unless $game_troop.interpreter.running?
      if $game_system.atb_turn_duration[0] >= $game_system.atb_turn_duration[1]
         $game_system.atb_turn_duration[0] = 0 
         $game_troop.increase_turn
         execute_event_phase if $game_troop.can_interpreter_running?(true)
      end  
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Turn
  #--------------------------------------------------------------------------             
  def update_turn?
      return false if $game_system.atb_turn_duration == nil or $game_system.atb_turn_duration[0] == nil
      return false if $game_temp.end_phase_duration[1] > 0
      return false if $game_temp.battle_end
      return false if $game_temp.atb_stop[1]    
      return true
  end    
  
  #--------------------------------------------------------------------------
  # ● Execute Event Phase
  #--------------------------------------------------------------------------             
  def execute_event_phase
      if $game_troop.can_interpreter_hide_window? or $game_troop.can_interpreter_hide_window_2?
      (record_window_data ; rw = true)
      end
      process_event
      refresh_status
      restore_window_data if rw != nil
      BattleManager.turn_start_abs      
  end    
  
  #--------------------------------------------------------------------------
  # ● Force Reset Turn Duration
  #--------------------------------------------------------------------------             
  def force_reset_turn_duration
      $game_temp.turn_duration_clear = false
      $game_system.atb_turn_duration[0] = 0
      $game_troop.set_turn(0)
  end  
  
  #--------------------------------------------------------------------------
  # ● ON Enemy OK
  #--------------------------------------------------------------------------
  alias mog_atb_on_enemy_ok on_enemy_ok
  def on_enemy_ok
      return if BattleManager.actor == nil
      return if battle_end?
      mog_atb_on_enemy_ok           
      BattleManager.command_end
      hide_base_window
  end
  
  #--------------------------------------------------------------------------
  # ● On Enemy Cancel
  #--------------------------------------------------------------------------
  alias mog_atb_on_enemy_cancel on_enemy_cancel
  def on_enemy_cancel
      return if BattleManager.actor == nil
      mog_atb_on_enemy_cancel
      start_actor_command_selection if @actor_command_window.active
      @skill_window.visible = true if @skill_window.active
      @item_window.visible = true if @item_window.active
  end     
  
  #--------------------------------------------------------------------------
  # ● On Actor OK
  #--------------------------------------------------------------------------
  alias mog_atb_on_actor_ok on_actor_ok
  def on_actor_ok
      return if BattleManager.actor == nil
      return if battle_end?
      mog_atb_on_actor_ok
      BattleManager.command_end
      hide_base_window
  end
  
  #--------------------------------------------------------------------------
  # ● On Actor Cancel
  #--------------------------------------------------------------------------
  alias mog_atb_on_actor_cancel on_actor_cancel
  def on_actor_cancel
      return if BattleManager.actor == nil
      mog_atb_on_actor_cancel
      start_actor_command_selection if @actor_command_window.active
      @skill_window.visible = true if @skill_window.active
      @item_window.visible = true if @item_window.active      
  end
  
  #--------------------------------------------------------------------------
  # ● On Skill Cancel
  #--------------------------------------------------------------------------
  alias mog_atb_on_skill_cancel on_skill_cancel
  def on_skill_cancel
      return if BattleManager.actor == nil
      mog_atb_on_skill_cancel
      start_actor_command_selection if @actor_command_window.active
  end  
  
  #--------------------------------------------------------------------------
  # ● On Item Cancel
  #--------------------------------------------------------------------------
  alias mog_atb_on_item_cancel on_item_cancel
  def on_item_cancel
      return if BattleManager.actor == nil
      mog_atb_on_item_cancel
      start_actor_command_selection if @actor_command_window.active
  end  
  
  #--------------------------------------------------------------------------
  # ● On Skill OK
  #--------------------------------------------------------------------------
  alias mog_atb_on_skill_ok on_skill_ok
  def on_skill_ok
      return if BattleManager.actor == nil
      @skill_window.visible = false unless !@status_window.visible
      mog_atb_on_skill_ok      
      if !@skill.need_selection?
         BattleManager.command_end
         hide_base_window
      end   
  end
   
  #--------------------------------------------------------------------------
  # ● On Item OK
  #--------------------------------------------------------------------------
  alias mog_atb_on_item_ok on_item_ok
  def on_item_ok
      return if BattleManager.actor == nil
      @item_window.visible = false unless !@status_window.visible
      mog_atb_on_item_ok
      if !@item.need_selection?
         BattleManager.command_end 
         hide_base_window
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Start Actor Command Selection
  #--------------------------------------------------------------------------
  def start_actor_command_selection(se = true)
      $game_temp.atb_user = BattleManager.actor
      $game_temp.refresh_actor_command = false
      $game_temp.actor_process_event = nil
      if BattleManager.next_command and BattleManager.actor and BattleManager.actor.movable_atb?
         execute_start_actor_command(se)
      else   
         BattleManager.command_selection_clear
      end   
  end     

  #--------------------------------------------------------------------------
  # ● Execute Start Actor Command
  #--------------------------------------------------------------------------
  def execute_start_actor_command(se)
      $game_temp.remove_order(BattleManager.actor)      
      Audio.se_play("Audio/SE/" + SE_ACTIVE,100,100) if se
      hide_base_window(false,true) if se 
      @status_window.select(BattleManager.actor.index)
      @status_window.open
      @status_window.select(BattleManager.actor.index)
      @party_command_window.close
      @actor_command_window.setup(BattleManager.actor)
      @actor_command_window.activate
      @actor_command_window.show
      @actor_command_window.index = $game_temp.actor_command_index      
  end
      
  #--------------------------------------------------------------------------
  # ● Next Command
  #--------------------------------------------------------------------------
  def next_command
  end
  
  #--------------------------------------------------------------------------
  # ● Close Base
  #--------------------------------------------------------------------------
  def close_base_window
      @party_command_window.close
      @actor_command_window.close
      @status_window.unselect
  end
    
  #--------------------------------------------------------------------------
  # ● Command Fight
  #--------------------------------------------------------------------------
  alias mog_atb_command_fight command_fight
  def command_fight
      mog_atb_command_fight
      start_actor_command_selection
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh Status
  #--------------------------------------------------------------------------
  alias mog_atb_refresh_status refresh_status
  def refresh_status
      mog_atb_refresh_status
      hide_windows_for_dead
  end

  #--------------------------------------------------------------------------
  # ● Forced Action Processing
  #--------------------------------------------------------------------------
  def process_forced_action    
      if BattleManager.action_forced?
         last_subject = @subject
         @subject = BattleManager.action_forced_battler         
         BattleManager.clear_action_force              
         execute_force_action         
         @subject = last_subject
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Force Action
  #--------------------------------------------------------------------------
  def execute_force_action
      return if scene_changing?
      if !@subject || !@subject.current_action
         @subject = BattleManager.next_subject
      end
      return turn_end unless @subject      
      if @subject.current_action        
         @subject.current_action.prepare
         if @subject.current_action.valid?
            @status_window.open
            execute_action
         end
         @subject.remove_current_action
       end
       process_action_end unless @subject.current_action 
  end  
  
  #--------------------------------------------------------------------------
  # ● Subject Action
  #--------------------------------------------------------------------------  
  def subject_action
      return @subject.current_action.item rescue nil
  end  
  
  #--------------------------------------------------------------------------
  # ● Wait for Effect
  #--------------------------------------------------------------------------  
  alias mog_atb_cm_wait_for_effect wait_for_effect
  def wait_for_effect
      return if $game_troop.interpreter.running?
      mog_atb_cm_wait_for_effect
  end
  
end

#===============================================================================
# ■ Window Battle Skill
#===============================================================================
class Window_BattleSkill < Window_SkillList
  
  #--------------------------------------------------------------------------
  # ● Select Last
  #--------------------------------------------------------------------------
  alias mog_atb_f_select_last_skill select_last
  def select_last
      act = @actor.last_skill.object rescue nil
      act_data = @data.index(@actor.last_skill.object) rescue nil
      if act == nil or act_data == nil ; select(0) ; return ; end
      mog_atb_f_select_last_skill
  end

end

#===============================================================================
# ■ Window Battle Item
#===============================================================================
class Window_BattleItem < Window_ItemList
  
  #--------------------------------------------------------------------------
  # ● Select Last
  #--------------------------------------------------------------------------
  alias mog_atb_f_select_last_item select_last
  def select_last
      act = $game_party.last_item.object rescue nil
      act_data = @data.index($game_party.last_item.object) rescue nil
      if act == nil or act_data == nil ; select(0) ; return ; end
      mog_atb_f_select_last_item
  end
  
end

#===============================================================================
# ■ Scene Battle
#===============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Skip Command?
  #--------------------------------------------------------------------------
  def skip_command?
      return true if BattleManager.actor == nil
      return true if BattleManager.actor.dead?
      return true if BattleManager.actor.restriction != 0
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Command Attack
  #--------------------------------------------------------------------------
  alias mog_atb_f_command_attack command_attack
  def command_attack
      if skip_command? ; break_command ; return ; end
      mog_atb_f_command_attack
  end

  #--------------------------------------------------------------------------
  # ● Command Skill
  #--------------------------------------------------------------------------
  alias mog_atb_f_command_skill command_skill
  def command_skill
      if skip_command? ; break_command ; return ; end
      mog_atb_f_command_skill
  end
 
  #--------------------------------------------------------------------------
  # ● Command Guard
  #--------------------------------------------------------------------------
  alias mog_atb_f_command_guard command_guard
  def command_guard
      if skip_command? ; break_command ; return ; end
      mog_atb_f_command_guard
      BattleManager.command_end
      hide_base_window      
  end
  
  #--------------------------------------------------------------------------
  # ● Command Item
  #--------------------------------------------------------------------------
  alias mog_atb_f_command_item command_item
  def command_item
      if skip_command? ; break_command ; return ; end
      mog_atb_f_command_item
  end  
  
end

#==============================================================================
# ■ SpritesetBattle
#==============================================================================
class Spriteset_Battle
  
  include MOG_ATB_SYSTEM
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  alias mog_atb_display_turn_initialize initialize
  def initialize
      create_turn_number
      mog_atb_display_turn_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  alias mog_atb_display_turn_dispose dispose
  def dispose
      mog_atb_display_turn_dispose
      dispose_turn_number
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------    
  alias mog_atb_display_turn_update update
  def update
      mog_atb_display_turn_update
      update_turn_number
  end

  #--------------------------------------------------------------------------
  # ● Create Turn Number
  #--------------------------------------------------------------------------    
  def create_turn_number
      return if !DISPLAY_TURN_NUMBER
      @turn_count_old = $game_troop.turn_count
      @turn_sprite = Sprite.new
      @turn_sprite.bitmap = Bitmap.new(120,32)
      @turn_sprite.bitmap.font.size = TURN_NUMBER_FONT_SIZE
      @turn_sprite.bitmap.font.bold = TURN_NUMBER_FONT_BOLD
      @turn_sprite.z = TURN_NUMBER_Z
      @turn_sprite.x = TURN_NUMBER_POS[0] ; @turn_sprite.y = TURN_NUMBER_POS[1]
      refresh_turn_sprite
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh Turn Sprite
  #--------------------------------------------------------------------------    
  def refresh_turn_sprite
      @turn_count_old = $game_troop.turn_count
      @turn_sprite.bitmap.clear ; @turn_sprite.opacity = 255
      turn_text = TURN_WORD + $game_troop.turn_count.to_s
      @turn_sprite.bitmap.draw_text(0,0,120,32,turn_text,0)
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Turn Number
  #--------------------------------------------------------------------------    
  def dispose_turn_number
      return if @turn_sprite == nil
      @turn_sprite.bitmap.dispose ; @turn_sprite.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Update Turn Number
  #--------------------------------------------------------------------------    
  def update_turn_number
      return if @turn_sprite == nil
      refresh_turn_sprite if @turn_count_old != $game_troop.turn_count
      @turn_sprite.visible = turn_visible?
  end
  
  #--------------------------------------------------------------------------
  # ● Turn Visible?
  #--------------------------------------------------------------------------    
  def turn_visible?
      return false if !$game_temp.sprite_visible
      return false if !$game_system.atb_sprite_turn
      return true
  end
  
end

#==============================================================================
# ■ Window BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable   
  include MOG_COOPERATION_SKILLS
  
  #--------------------------------------------------------------------------
  # ● Display Skill/Item Use
  #--------------------------------------------------------------------------
  alias mog_cskill_display_use_item display_use_item
  def display_use_item(subject, item)
      return if cooperation_skill_users?(subject, item)
      mog_cskill_display_use_item(subject, item)
  end
  
  #--------------------------------------------------------------------------
  # ● Cooperation Skill_users?
  #--------------------------------------------------------------------------
  def cooperation_skill_users?(subject, item)
      return false if subject.is_a?(Game_Enemy)
      return false if !item.is_a?(RPG::Skill)
      return false if !BattleManager.is_cskill?(item.id)
      return false if !BattleManager.actor_included_in_cskill?(subject.id,item.id)
      members = BattleManager.cskill_members(item.id) ; subject_name = ""
      if members.size <=0  
         members.each_with_index do |b,index|     
         if index == members.size - 1 ; subject_name += b.name
         else ; subject_name += b.name + " " + "and" + " " 
         end
         end 
      else
         subject_name += $game_party.name
      end
      add_text(subject_name + item.message1)
      unless item.message2.empty? ; wait ; add_text(item.message2) ; end
  end
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_BattlerBase  

  #--------------------------------------------------------------------------
  # ● Pay Skill Cost
  #--------------------------------------------------------------------------    
  alias mog_cskill_pay_skill_cost pay_skill_cost
  def pay_skill_cost(skill)
      if self.is_a?(Game_Actor) and BattleManager.cskill_usable?(skill.id,self.id)
           BattleManager.pay_cskill_cost(skill)
         return
      end
      mog_cskill_pay_skill_cost(skill)
  end

end

#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  include MOG_COOPERATION_SKILLS
  
  #--------------------------------------------------------------------------
  # ● Cooperation Skill Enable?
  #--------------------------------------------------------------------------
  def self.cskill_enable?(skill_id)
      return false if actor == nil
      return false if !actor_included_in_cskill?(actor.id,skill_id)
      return false if !ckill_members_usable?(skill_id)
      return false if !cskill_all_members_available?(skill_id)
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Cskill Usable?
  #--------------------------------------------------------------------------
  def self.cskill_usable?(skill_id,actor_id)
      return false if !is_cskill?(skill_id)
      return false if !actor_included_in_cskill?(actor_id,skill_id)
      return false if !cskill_members_alive?(skill_id)
      return true
  end  
  
  #--------------------------------------------------------------------------
  # ● Pay Cskill Cost
  #--------------------------------------------------------------------------
  def self.pay_cskill_cost(skill)
      cskill_members(skill.id).each do |battler| 
         battler.face_animation = [60 ,2,0] if $imported[:mog_battle_hud_ex]
         $game_temp.remove_order(battler)
         battler.mp -= battler.skill_mp_cost(skill)
         battler.tp -= battler.skill_tp_cost(skill)
      end
  end   
    
  #--------------------------------------------------------------------------
  # ● Cskill Members Usable?
  #--------------------------------------------------------------------------
  def self.ckill_members_usable?(skill_id)
      skill = $data_skills[skill_id] rescue nil
      return false if skill == nil    
      cskill_members(skill_id).each do |battler| 
           return false if !battler.atb_max?
           return false if battler == subject
           return false if battler.restriction != 0
           return false if !battler.skill_cost_payable?(skill)
           return false if !battler.usable?(skill)
      end
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Cskill Actor?
  #--------------------------------------------------------------------------
  def self.ckill_actor?(self_actor)
      item = self_actor.current_action.item rescue nil
      return false if item == nil
      include = false
      cskill_members(item.id).each do |battler| 
      include = true if self_actor == battler
      end  
      return true if include
      return false
  end  
  
  #--------------------------------------------------------------------------
  # ● Cskill All Members Available?
  #--------------------------------------------------------------------------
  def self.cskill_all_members_available?(skill_id)
      return false if COOPERATION_SKILLS[skill_id].size != cskill_members(skill_id).size
      return true
  end  
    
  #--------------------------------------------------------------------------
  # ● Cooperation Members
  #--------------------------------------------------------------------------
  def self.cskill_members(skill_id)
      return [] if COOPERATION_SKILLS[skill_id].nil?
      members = []
      $game_party.battle_members.each do |battler| 
      members.push(battler) if COOPERATION_SKILLS[skill_id].include?(battler.id)
      end
      return members
  end
  
  #--------------------------------------------------------------------------
  # ● Cskill Members Skill Cost?
  #--------------------------------------------------------------------------
  def self.cskill_members_skill_cost?(skill_id)
      skill = $data_skills[skill_id] rescue nil
      return false if skill == nil
      cskill_members(skill_id).each do |battler|
      return false if !battler.skill_conditions_met?(skill)
      end
      return true
  end  
    
  #--------------------------------------------------------------------------
  # ● Cskill Members Usable?
  #--------------------------------------------------------------------------
  def self.cskill_members_alive?(skill_id)
      skill = $data_skills[skill_id] rescue nil
      return false if skill == nil    
      alive = true
      cskill_members(skill_id).each do |battler| 
          alive = false if battler.dead?
          alive = false if battler.restriction != 0
          alive = false if !battler.skill_cost_payable?(skill)
      end 
      if !alive
         force_clear_cskill(skill_id)
         return false
      end
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Force Clear Cskill
  #--------------------------------------------------------------------------
  def self.force_clear_cskill(skill_id)
      cskill_members(skill_id).each do |battler| battler.turn_clear
      battler.atb_cast.clear
      battler.bact_sprite_need_refresh = true if $imported[:mog_sprite_actor]
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Cast Action Members
  #--------------------------------------------------------------------------
  def self.execute_cast_action_members(skill_id)
      cskill_members(skill_id).each do |battler| 
         battler.next_turn = true 
         battler.atb = battler.atb_max 
         battler.atb_cast.clear
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Set Members CP Skills
  #--------------------------------------------------------------------------
  def self.set_members_cp_skill(skill_id)
      skill = $data_skills[skill_id] rescue nil
      return false if skill == nil    
      cskill_members(skill_id).each do |battler| 
           battler.atb = 0
           battler.actions = @command_actor.actions if @command_actor.actions != nil
           $game_temp.remove_order(battler)
           if skill.speed.abs == 0
              battler.atb_cast = [skill,50,50] 
           else
              battler.atb_cast = [skill,skill.speed.abs,0]
           end
           battler.animation_id = MOG_COOPERATION_SKILLS::COOPERATION_SKILL_ANIMATION
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Clear Members Cp Skill
  #--------------------------------------------------------------------------
  def self.clear_members_ckill(subject)
      return if subject.is_a?(Game_Enemy)
      return if subject == nil
      skill = subject.current_action.item rescue nil
      return if skill == nil
      return if !is_cskill?(skill.id)
      return if !actor_included_in_cskill?(subject.id,skill.id)
      cskill_members(skill.id).each do |battler| battler.turn_clear ; end 
  end
  
  #--------------------------------------------------------------------------
  # ● Actor Included in Cooperation Skill?
  #--------------------------------------------------------------------------
  def self.actor_included_in_cskill?(actor_id,skill_id)
      return false if !SceneManager.scene_is?(Scene_Battle)
      return false if !is_cskill?(skill_id)
      return false if !COOPERATION_SKILLS[skill_id].include?(actor_id)
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Is Cooperation Skill?
  #--------------------------------------------------------------------------
  def self.is_cskill?(skill_id)
      return false if !SceneManager.scene_is?(Scene_Battle)
      return false if COOPERATION_SKILLS[skill_id].nil?
      return true
  end
  
end

#==============================================================================
# ■ BattleManager
#==============================================================================
class << BattleManager
  
  #--------------------------------------------------------------------------
  # ● Set Cast Action
  #--------------------------------------------------------------------------
  alias mog_cskill_command_end_actor command_end_actor
  def command_end_actor
      prepare_ckill_members
      mog_cskill_command_end_actor      
  end
  
  #--------------------------------------------------------------------------
  # ● Prepare Cskill Members
  #--------------------------------------------------------------------------
  def prepare_ckill_members
      item = @command_actor.current_action.item rescue nil  
      return if item == nil
      if is_cskill?(item.id) and ckill_members_usable?(item.id)
          set_members_cp_skill(item.id)
          @command_actor = nil
      end  
  end
    
  #--------------------------------------------------------------------------
  # ● Clear Cskills Members
  #--------------------------------------------------------------------------
  def clear_cskill_members(subject)
      item = subject.current_action.item rescue nil  
      return if item == nil
      clear_members_ckill(item.id) if is_cskill?(item.id)
  end
  
end

#==============================================================================
# ■ Window SkillList
#==============================================================================
class Window_SkillList < Window_Selectable
  
  #--------------------------------------------------------------------------
  # ● Display Skill in Active State?
  #--------------------------------------------------------------------------
  alias mog_atb_skill_list_enable? enable?
  def enable?(item)
      if SceneManager.scene_is?(Scene_Battle) and !item.nil?
         return false if BattleManager.is_cskill?(item.id) and !BattleManager.cskill_enable?(item.id)
      end
      mog_atb_skill_list_enable?(item)
  end    

end

#==============================================================================
# ■ Game Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # ● Calculate Damage
  #--------------------------------------------------------------------------
  alias mog_atb_make_make_damage_value make_damage_value
  def make_damage_value(user, item)
      mog_atb_make_make_damage_value(user, item)
      coop_make_damage_value(user, item) if coop_make_damage_value?(user, item)
  end
  
  #--------------------------------------------------------------------------
  # ● Calculate Damage
  #--------------------------------------------------------------------------
  def coop_make_damage_value?(user, item)
      return false if item == nil
      return false if user.is_a?(Game_Enemy)
      return false if item.is_a?(RPG::Item)
      return false if !BattleManager.is_cskill?(item.id)
      return false if BattleManager.cskill_members(item.id).size < 1
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Coop Make Damage Value
  #--------------------------------------------------------------------------
  def coop_make_damage_value(user, item)
      for actor in BattleManager.cskill_members(item.id)
          next if actor == user
          value = item.damage.eval(actor, self, $game_variables)
          value *= item_element_rate(actor, item)
          value *= pdr if item.physical?
          value *= mdr if item.magical?
          value *= rec if item.damage.recover?
          value = apply_critical(value) if @result.critical
          value = apply_variance(value, item.damage.variance)
          value = apply_guard(value)
          @result.make_damage_coop(value.to_i, item)
      end
      @result.make_damage_coop_after(item)
  end
  
end

#==============================================================================
# ■ Game ActionResult
#==============================================================================
class Game_ActionResult
  
  #--------------------------------------------------------------------------
  # ● Create Damage
  #--------------------------------------------------------------------------
  def make_damage_coop(value, item)
      @hp_damage += value if item.damage.to_hp?
      @mp_damage += value if item.damage.to_mp?
  end    
     
  #--------------------------------------------------------------------------
  # ● Make Damage Coop After
  #--------------------------------------------------------------------------
  def make_damage_coop_after(item)
      @hp_damage /= BattleManager.cskill_members(item.id).size if item.damage.to_hp?
      @mp_damage /= BattleManager.cskill_members(item.id).size if item.damage.to_mp?    
      @critical = false if @hp_damage == 0
      @mp_damage = [@battler.mp, @mp_damage].min
      @hp_drain = @hp_damage if item.damage.drain?
      @mp_drain = @mp_damage if item.damage.drain?
      @hp_drain = [@battler.hp, @hp_drain].min
      @success = true if item.damage.to_hp? || @mp_damage != 0
  end
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # ● Execute Cast Action
  #--------------------------------------------------------------------------    
  alias mog_cskill_execute_cast_action execute_cast_action
  def execute_cast_action
      mog_cskill_execute_cast_action
      prepare_cast_action_members
  end
  
  #--------------------------------------------------------------------------
  # ● Prepare Cast Acton Members
  #--------------------------------------------------------------------------    
  def prepare_cast_action_members
      return if self.is_a?(Game_Enemy)
      item = self.current_action.item rescue nil  
      return if item == nil    
      BattleManager.execute_cast_action_members(item.id) if BattleManager.cskill_usable?(item.id,self.id)
  end
  
  #--------------------------------------------------------------------------
  # ● ATB After Damage
  #--------------------------------------------------------------------------  
  alias mog_cpskill_atb_after_damage atb_after_damage
  def atb_after_damage(pre_item = nil)
      mog_cpskill_atb_after_damage(pre_item)
      force_clear_cpkill(pre_item) if pre_item != nil and self.is_a?(Game_Actor)
  end  
  
  #--------------------------------------------------------------------------
  # ● Force Clear CP skill
  #--------------------------------------------------------------------------    
  def force_clear_cpkill(pre_item = nil)
      $game_temp.refresh_item_window = true if @result.mp_damage != 0
      BattleManager.cskill_usable?(pre_item.id,self.id) if pre_item != nil      
  end

  #--------------------------------------------------------------------------
  # ● Need Refresh Item Window?
  #--------------------------------------------------------------------------    
  alias mog_cskills_need_refresh_item_window? need_refresh_item_window?
  def need_refresh_item_window?
      return true
      mog_cskills_need_refresh_item_window?
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Damage
  #--------------------------------------------------------------------------    
  alias mog_atb_coop_execute_damage execute_damage
  def execute_damage(user)
      mog_atb_coop_execute_damage(user)
      item = user.current_action.item rescue nil
      execute_damage_coop(user,item) if user.coop_make_damage_value?(user, item)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Damage Coop
  #--------------------------------------------------------------------------    
  def execute_damage_coop(user,item)
      for actor in BattleManager.cskill_members(item.id)
          next if actor == user
          actor.hp += @result.hp_drain
          actor.mp += @result.mp_drain
          if $imported[:mog_damage_popup]
             actor.damage.push([-@result.hp_drain,"HP",@result.critical]) if @result.hp_drain != 0
             actor.damage.push([-@result.mp_drain,"MP",@result.critical]) if @result.mp_drain != 0
          end    
      end    
  end
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # ● Process Before Execute Action
  #--------------------------------------------------------------------------  
  alias mog_cskill_process_before_execute_action  process_before_execute_action 
  def process_before_execute_action
      mog_cskill_process_before_execute_action
      before_execute_cooperation_skill if can_execute_cooperation_skill?
  end

  #--------------------------------------------------------------------------
  # ● Process Before Remove Action
  #--------------------------------------------------------------------------  
  alias mog_cskill_process_before_remove_action process_before_remove_action
  def process_before_remove_action
      mog_cskill_process_before_remove_action
      BattleManager.clear_members_ckill(@subject)
  end

  #--------------------------------------------------------------------------
  # ● Can Execute Cooperation Skill?
  #--------------------------------------------------------------------------  
  def can_execute_cooperation_skill?
      return false if !@subject.is_a?(Game_Actor)
      item = @subject.current_action.item rescue nil
      return false if item == nil
      return false if !BattleManager.cskill_usable?(item.id,@subject.id)
      return true
  end

  #--------------------------------------------------------------------------
  # ● Current CP Members
  #--------------------------------------------------------------------------
  def current_cp_members
      return [] if subject_action == nil
      return BattleManager.cskill_members(subject_action.id)
  end    
  
  #--------------------------------------------------------------------------
  # ● Before Execute Coomperation Skill. (add-ons)
  #--------------------------------------------------------------------------  
  def before_execute_cooperation_skill
  end

end