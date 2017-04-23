#==============================================================================
# +++ MOG - Active Bonus Gauge (1.5) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Sistema de bônus ativo de batalha onde o medidor tem um tempo limite de uso,
# os efeitos duram apenas enquanto o medidor estiver ativo, em alguns casos
# como o bônus de experiência, se o jogador não finalizar a batalha a tempo,
# o bônus será anulado.
#
# Efeitos (Aleatórios)
# - Inimigos recebem o dobro de dano.
# - Aliados recebem apenas a metade do dano.
# - Dobra a Exp recebida no final da batalha.
# - Dobra o dinheiro recebido no final da batalha.
# - Dobra a probabilidade de receber tesouros.
#
#==============================================================================
# Para definir um valor específico de ganho no medidor de bônus, coloque o
# comentário abaixo na caixa de notas das habilidades ou itens.
#
# <Bonus Point = X>
# X - Valor adicionado ao medidor de bônus.
#
# Caso você não defina nada o valor ganho será aleatório.
#
#==============================================================================
# Imagens necessárias. (Graphics/System/)
#
# Bonus_Gauge_1.png
# Bonus_Gauge_2.png
# Bonus_Icons.png
# Bonus_Word.png
# Bonus_Back_0.png      (Opcional)
# Bonus_Back_1.png      (Opcional)
# Bonus_Back_2.png      (Opcional)
# Bonus_Back_3.png      (Opcional)
# Bonus_Back_4.png      (Opcional)
#
#==============================================================================
# Atualizações desta versão. 
#==============================================================================
# (Ver 1.5)
# - Correção do Crash quando o script não é usado junto com Battle Result script.
#==============================================================================
module MOG_BONUS_GAUGE
  
  # Definição do comportamento do medidor ao chegar no nível máximo.
  # 0 - WAIT
  #     O medidor não diminui ao chegar ao nível máximo.
  # 1 - SEMI ACTIVE  
  #     O medidor não diminui enquanto o jogador estiver selecionando
  #     os comandos.
  # 2 - ACTIVE
  #     O medidor diminui em qualquer situação.
  
  ACTIVE_GAUGE_TYPE = 1
  
  #Ativar a penalidade de dano.
  #O medidor diminui quando os alidados recebem dano.
  DAMAGE_PENALTY = true
  
  #Definição dos pontos ganhos no medidor de bônus, caso a habilidade não
  #estiver especificada com a tag <Bonus Point = X>.
  DEFAULT_RAND_POINTS = 10 #Valores aletórios entre...
  
  #Definição da velocidade do medidor ao diminuir.
  BONUS_EFFECT_SPEED = 15  
  
  #Definição da porcentagem de dano extra no bônus de attack.
  BONUS_POWER_PERC = 100
  
  #Definição da porcentagem de bônus de defesa.
  BONUS_DEFENSE_PERC = 50
  
  #Posição geral do sprite do bônus.
  BONUS_SPRITE_POSITION = [2,40]
  
  #Posição do medidor do medidor.
  METER_SPRITE_POSITION = [9,29]
  
  #Posição do ícone.
  ICON_POSITION = [-1,3]
  
  #Posição do texto
  TEXT_SPRITE_POSITION = [37,80]
  
  #Cor do texto
  TEXT_COLOR = Color.new(255,150,50,255)

  #Definição do texto para cada efeito.
  TEXT_HELP = [
  "Attack x 2",
  "Defense x 2",
  "Exp x 2",
  "Gold x 2",
  "Treasure % x 2",
  "Bonus Gauge"
  ]

  #Som quando o medidor chegar ao nível máximo.
  SE_BONUS_ON = "Up1"
  
  #Som quando o medidor chegar a zero.
  SE_BONUS_OFF = "Down2"
  
  #Prioridade do sprite.
  PRIORITY_Z = 91
end

$imported = {} if $imported.nil?
$imported[:mog_active_bonus_gauge] = true

#==============================================================================
# ■ Battle Manager
#==============================================================================
class << BattleManager
 
  #--------------------------------------------------------------------------
  # ● Process Victory
  #--------------------------------------------------------------------------      
  alias mog_battle_result_process_victory process_victory
  def process_victory
     $game_temp.battle_end = true
     mog_battle_result_process_victory
  end
   
  #--------------------------------------------------------------------------
  # ● Process Defeat
  #--------------------------------------------------------------------------      
  alias mog_battle_result_process_defeat process_defeat
  def process_defeat
      $game_temp.battle_end = true
      mog_battle_result_process_defeat
  end
  
  #--------------------------------------------------------------------------
  # ● Process Abort
  #--------------------------------------------------------------------------      
  alias mog_battle_result_process_abort process_abort
  def process_abort
      $game_temp.battle_end = true
      mog_battle_result_process_abort
  end
  
  #--------------------------------------------------------------------------
  # ● Phase Nil?
  #--------------------------------------------------------------------------      
  def phase_nil?
      @phase == nil
   end  
  
end

#==============================================================================
# ■ Game System
#==============================================================================
class Game_System
  
  attr_accessor :bonus_gauge
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  alias mog_bonus_gauge_initialize initialize
  def initialize
      @bonus_gauge = [0,100,5,false,0]
      mog_bonus_gauge_initialize
  end
  
end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  
  attr_accessor :cache_active_bonus
  attr_accessor :battle_end 
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_active_bonus_initialize initialize
  def initialize
      @battle_end = false
      mog_active_bonus_initialize
      cache_act_bonus
  end
  
  #--------------------------------------------------------------------------
  # ● Cache Act Bonus
  #--------------------------------------------------------------------------    
  def cache_act_bonus
      @cache_active_bonus = []
      @cache_active_bonus.push(Cache.system("Bonus_Gauge_1"))
      @cache_active_bonus.push(Cache.system("Bonus_Gauge_2"))
      @cache_active_bonus.push(Cache.system("Bonus_Icons"))
  end
  
end

#==============================================================================
# ■ Bonnus Gauge
#==============================================================================
class Bonus_Gauge
  
  include MOG_BONUS_GAUGE
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  def initialize
      @bonus_duration = BONUS_EFFECT_SPEED rescue nil
      $game_system.bonus_gauge = [0,100,5,false,0]
      create_bonus_gauge_layout ; create_bonus_gauge_meter
      create_bonus_text ; create_bonus_icons
  end

  #--------------------------------------------------------------------------
  # ● Create Bonus Gauge Layout
  #--------------------------------------------------------------------------    
  def create_bonus_gauge_layout
      @bg_layout = Sprite.new
      @bg_layout.bitmap = $game_temp.cache_active_bonus[0]
      @bg_layout.z = PRIORITY_Z ; @bg_layout.opacity = 0
      @bg_layout.x = BONUS_SPRITE_POSITION[0]
      @bg_layout.y = BONUS_SPRITE_POSITION[1] 
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Bonus Gauge Meter
  #--------------------------------------------------------------------------      
  def create_bonus_gauge_meter
      @bg_image =  $game_temp.cache_active_bonus[1]
      @bg_cw = @bg_image.width / 2 ; @bg_ch = @bg_image.height
      @bg_meter = Sprite.new ; @bg_meter.z = PRIORITY_Z + 1
      @bg_meter.x = BONUS_SPRITE_POSITION[0] + METER_SPRITE_POSITION[0]
      @bg_meter.y = BONUS_SPRITE_POSITION[1] + METER_SPRITE_POSITION[1]
      @bg_meter.bitmap = Bitmap.new(@bg_cw,@bg_ch) ; @bg_meter.opacity = 0
      @old_bg = -1 ; refresh_bonus_meter
  end  

  #--------------------------------------------------------------------------
  # ● Create Bonus Text
  #--------------------------------------------------------------------------     
  def create_bonus_text
      @bg_text = Sprite.new ; @bg_text.z = PRIORITY_Z + 2
      @bg_text.bitmap = Bitmap.new(190,32) ; @bg_text.opacity = 0
      @bg_text.bitmap.font.bold = true ; @bg_text.bitmap.font.size = 18
      @bg_text.ox = @bg_text.bitmap.width / 2 
      @bg_text.oy = @bg_text.bitmap.height / 2
      @bg_text.x = BONUS_SPRITE_POSITION[0] + TEXT_SPRITE_POSITION[0] - @bg_text.oy
      @bg_text.y = BONUS_SPRITE_POSITION[1] + TEXT_SPRITE_POSITION[1] + @bg_text.ox     
      @bg_text_pop = -1 ; @bg_text.angle = 270 ; refresh_bonus_text
   end   

  #--------------------------------------------------------------------------
  # ● Refresh Bonus text
  #--------------------------------------------------------------------------        
  def refresh_bonus_text
      return if @bg_text_pop == $game_system.bonus_gauge[2]
      update_bonus_animation if $game_system.bonus_gauge[2] != 5
      @bg_text_pop = $game_system.bonus_gauge[2] ; @bg_text.bitmap.clear
      text_pop = TEXT_HELP[$game_system.bonus_gauge[2]]      
      @bg_text.bitmap.font.color = Color.new(0,0,0)
      @bg_text.bitmap.draw_text(2,2,180,32,text_pop,0 )
      @bg_text.bitmap.font.color = TEXT_COLOR
      @bg_text.bitmap.draw_text(0,0,180,32,text_pop,0 )
      @bg_text.zoom_x = 1.5 ; @bg_text.zoom_y = 1.5 ; @bg_text.opacity = 255
  end

  #--------------------------------------------------------------------------
  # ● Refresh Bonus Meter
  #--------------------------------------------------------------------------   
  def refresh_bonus_meter
      return if @old_bg == $game_system.bonus_gauge[0]
      @old_bg = $game_system.bonus_gauge[0] ; @bg_meter.bitmap.clear
      meter_height = $game_system.bonus_gauge[0] * @bg_image.height / $game_system.bonus_gauge[1]
      meter_type = $game_system.bonus_gauge[3] == true ? @bg_cw : 0
      bg_scr = Rect.new(meter_type,-@bg_image.height + meter_height,@bg_cw, @bg_ch)
      @bg_meter.bitmap.blt(0,0,@bg_image, bg_scr )      
  end  

  #--------------------------------------------------------------------------
  # ● Create Bonus Icons
  #--------------------------------------------------------------------------     
  def create_bonus_icons
      @bonus_icons_image = $game_temp.cache_active_bonus[2] 
      @bonus_icons = Sprite.new ; @bonus_icons.bitmap = Bitmap.new(24,24)
      @bonus_icons.x = BONUS_SPRITE_POSITION[0] + ICON_POSITION[0]
      @bonus_icons.y = BONUS_SPRITE_POSITION[1] + ICON_POSITION[1]
      @bonus_icons.z = PRIORITY_Z + 2 ; @bonus_icons.opacity = 0
      @bonus_index = -1 ; refresh_icons
  end  
   
  #--------------------------------------------------------------------------
  # ● Refresh Icons
  #--------------------------------------------------------------------------       
  def refresh_icons
      return if @bonus_index == $game_system.bonus_gauge[2]
      @bonus_index = $game_system.bonus_gauge[2] ; @bonus_icons.bitmap.clear
      icon_index = 24 * $game_system.bonus_gauge[2]
      icon_scr = Rect.new(icon_index,0,24,24)
      @bonus_icons.bitmap.blt(0,0,@bonus_icons_image, icon_scr)
  end  
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  def dispose
      dispose_bonus_gauge_layout ; dispose_bonus_gauge_meter
      dispose_bonus_text ; dispose_bonus_icon
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Bonus Icon
  #--------------------------------------------------------------------------    
  def dispose_bonus_icon
      return if @bonus_icons == nil
      @bonus_icons.bitmap.dispose ; @bonus_icons.dispose
  end  
  
  #--------------------------------------------------------------------------
  # ● Dispose Bonus Gauge Layout
  #--------------------------------------------------------------------------    
  def dispose_bonus_gauge_layout
      return if @bg_layout == nil
      @bg_layout.dispose
  end

  #--------------------------------------------------------------------------
  # ● Dispose Bonus Gauge Meter
  #--------------------------------------------------------------------------    
  def dispose_bonus_gauge_meter
      return if @bg_meter == nil
      @bg_meter.bitmap.dispose ; @bg_meter.dispose
  end

  #--------------------------------------------------------------------------
  # ● Dispose Bonus Text
  #--------------------------------------------------------------------------      
  def dispose_bonus_text
      return if @bg_text == nil
      @bg_text.bitmap.dispose ; @bg_text.dispose
  end
    
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  def update
      if can_update_bonus_base?
         update_bonus_time ; update_text_effect ; update_sprite_opacity(10)
      else
         update_sprite_opacity(-10)
      end  
      refresh_bonus_meter ; refresh_bonus_text ; refresh_icons
  end
  
  #--------------------------------------------------------------------------
  # ● Update Sprite Opacity
  #--------------------------------------------------------------------------  
  def update_sprite_opacity(value)
      @bg_meter.opacity += value ; @bg_layout.opacity += value
      @bonus_icons.opacity += value ; @bg_text.opacity += value
  end  
    
  #--------------------------------------------------------------------------
  # ● Can Update Bonus Base
  #--------------------------------------------------------------------------  
  def can_update_bonus_base?
      return false if $game_temp.battle_end 
      return false if $game_message.visible
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Can Update Bonus
  #--------------------------------------------------------------------------    
  def can_update_bonus?
      return false if ACTIVE_GAUGE_TYPE == 0 
      return false if ACTIVE_GAUGE_TYPE == 1 and BattleManager.actor != nil
      return false if BattleManager.phase_nil?
      return false if BattleManager.aborting?      
      return true 
  end      
       
  #--------------------------------------------------------------------------
  # ● Update Bonus Time
  #--------------------------------------------------------------------------    
  def update_bonus_time
      return if !can_update_bonus? 
      return if !$game_system.bonus_gauge[3] 
      $game_system.bonus_gauge[4] += 1
      if $game_system.bonus_gauge[4] > @bonus_duration
         $game_system.bonus_gauge[4] = 0 ; $game_system.bonus_gauge[0] -= 1
         if $game_system.bonus_gauge[0] <= 0
            $game_system.bonus_gauge[3] = false
            $game_system.bonus_gauge[2] = 5
            Audio.se_play("Audio/SE/" + SE_BONUS_OFF,100,100)
         end
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Update Text Effect
  #--------------------------------------------------------------------------      
  def update_text_effect
      return if @bg_text.zoom_x == 1.00
      @bg_text.zoom_x -= 0.01 ; @bg_text.opacity += 5
      (@bg_text.zoom_x = 1.00 ; @bg_text.opacity = 255) if @bg_text.zoom_x <= 1.00
      @bg_text.zoom_y = @bg_text.zoom_x
  end
  
end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Spriteset_Battle
  
  include MOG_BONUS_GAUGE
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  alias mog_bonus_gauge_initialize initialize
  def initialize
      mog_bonus_gauge_initialize
      create_bonus_gauge
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------   
  alias mog_bonus_gauge_dispose dispose
  def dispose
      mog_bonus_gauge_dispose 
      dispose_bonus_gauge
  end

  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------    
  alias mog_bonus_gauge_update update
  def update
      mog_bonus_gauge_update
      update_bonus_gauge      
  end
  
  #--------------------------------------------------------------------------
  # ● Create Bonus Gauge
  #--------------------------------------------------------------------------      
  def create_bonus_gauge
      @bgauge = Bonus_Gauge.new
  end  
  
  #--------------------------------------------------------------------------
  # ● Dispose Bonus Gauge
  #--------------------------------------------------------------------------      
  def dispose_bonus_gauge
      return if @bgauge == nil 
      @bgauge.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Update Bonus Gauge
  #--------------------------------------------------------------------------      
  def update_bonus_gauge
      return if @bgauge == nil 
      @bgauge.update 
  end
  
end

#==============================================================================
# ■ Bonnus Gauge
#==============================================================================
class Bonus_Gauge
   
  #--------------------------------------------------------------------------
  # ● update Bonus Animation
  #--------------------------------------------------------------------------        
  def update_bonus_animation
      bonus_anime = Bonus_Gauge_Animation.new
      loop do
           bonus_anime.update ; Graphics.update ; Input.update
           break if bonus_anime.phase == 3
      end  
      bonus_anime.dispose
  end
  
end

#==============================================================================
# ■ Bonnus Gauge Animation
#==============================================================================
class Bonus_Gauge_Animation
  attr_accessor :phase
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------          
  def initialize
      @phase = 0 ; @phase_duration = 0 ; create_stp
  end
  
  #--------------------------------------------------------------------------
  # ● Create Stp
  #--------------------------------------------------------------------------            
  def create_stp    
      @stp1 = Sprite.new ; @stp1.bitmap = Cache.system("Bonus_Word")
      @stp1.opacity = 0 ; @stp1.z = 1003
      @stp1.ox = @stp1.bitmap.width / 2 ; @stp1.oy = @stp1.bitmap.height / 2 
      @stp1.x = @stp1.ox ; @stp1.y = @stp1.oy
      @stp1.zoom_x = 2.00 ; @stp1.zoom_y = 2.00
      @stp2 = Sprite.new
      @stp2.bitmap = Cache.system("Bonus_Back_" + $game_system.bonus_gauge[2].to_s) rescue nil
      @stp2.opacity = 255 ;  @stp2.z = 1002
      if @stp2.bitmap != nil
         @stp2.ox = @stp2.bitmap.width / 2 ; @stp2.oy = @stp2.bitmap.height / 2 
      end   
      @stp2.x = @stp2.ox ; @stp2.y = @stp2.oy
      @stp2.zoom_x = 1.50 ; @stp2.zoom_y = 1.50       
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------          
  def dispose
      @stp1.bitmap.dispose ; @stp1.dispose 
      @stp2.bitmap.dispose if @stp2.bitmap ; @stp2.dispose      
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------          
  def update
      return if @phase == 3
      case @phase 
        when 0; update_start
        when 1; update_stand
        when 2; update_end      
      end
      @stp2.opacity -= 3  
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Start
  #--------------------------------------------------------------------------            
  def update_start
      @stp1.zoom_x -= 0.05 ; @stp1.zoom_y -= 0.05 ; @stp1.opacity += 5
      @stp2.zoom_x -= 0.002 ; @stp2.zoom_y -= 0.002      
      return if @stp1.zoom_x > 1.1
      @stp1.zoom_x = 1.00 ; @stp1.zoom_y = 1.00 ; @stp1.opacity = 255
      @phase = 1 ; @phase_duration = 20
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Stand
  #--------------------------------------------------------------------------            
  def update_stand
      @phase_duration -= 1 ; @stp2.zoom_x -= 0.002 ; @stp2.zoom_y -= 0.002     
      return if @phase_duration > 0      
      @phase = 2      
  end
  
  #--------------------------------------------------------------------------
  # ● Update End
  #--------------------------------------------------------------------------              
  def update_end  
      @stp1.zoom_x += 0.05 ; @stp1.zoom_y += 0.05 ; @stp2.zoom_x += 0.02
      @stp2.zoom_y += 0.02 ; @stp1.opacity -= 5      
      return if @stp1.opacity > 0
      @phase = 3 
  end   
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  include MOG_BONUS_GAUGE
  
  #--------------------------------------------------------------------------
  # ● Execute Damage
  #--------------------------------------------------------------------------      
  alias mog_bonus_gauge_execute_damage execute_damage
  def execute_damage(user)
      check_bonus_gauge(user)
      mog_bonus_gauge_execute_damage(user)
  end
  
  #--------------------------------------------------------------------------
  # ● Check Bonus Gauge
  #--------------------------------------------------------------------------        
  def check_bonus_gauge(user)
      execute_bonus_effect(user)
      add_gauge_point(user)
  end

  #--------------------------------------------------------------------------
  # ● Execute Bonus Effect
  #--------------------------------------------------------------------------          
  def execute_bonus_effect(user)
      return if !$game_system.bonus_gauge[3]
      if can_bonus_defense_effect?(user) and @result.hp_damage > 1
         dmg2 = @result.hp_damage * BONUS_DEFENSE_PERC / 100
         dmg = @result.hp_damage - dmg2 ; dmg = 0 if dmg < 0
         @result.hp_damage = dmg ; @result.hp_damage = 0 if @result.hp_damage < 0 
       elsif can_bonus_power_effect?(user)
         dmg = @result.hp_damage * BONUS_POWER_PERC / 100
         @result.hp_damage += dmg
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Can Bonus Defense Effect?
  #--------------------------------------------------------------------------            
  def can_bonus_defense_effect?(user)
      return false if self.is_a?(Game_Enemy)
      return false if user.is_a?(Game_Actor)
      return false if $game_system.bonus_gauge[2] != 1
      return true
  end

  #--------------------------------------------------------------------------
  # ● Can Bonus Power Effect?
  #--------------------------------------------------------------------------            
  def can_bonus_power_effect?(user)
      return false if self.is_a?(Game_Actor)
      return false if user.is_a?(Game_Enemy)
      return false if $game_system.bonus_gauge[2] != 0
      return true
  end  
  
  #--------------------------------------------------------------------------
  # ● Check Gauge Limit
  #--------------------------------------------------------------------------          
  def check_gauge_limit
      $game_system.bonus_gauge[0] = 100 if $game_system.bonus_gauge[0] > 100
      $game_system.bonus_gauge[0] = 0 if $game_system.bonus_gauge[0] < 0    
  end  
  
  #--------------------------------------------------------------------------
  # ● Add Gauge Point Actor Damage
  #--------------------------------------------------------------------------          
  def add_gauge_point(user)
      return if @result.hp_damage <= 0
      return if $game_system.bonus_gauge[3]
      battler_action = user.actions[0].item rescue nil
      return if battler_action == nil
      if battler_action.note =~ /<Bonus Point = (\d+)>/i  
         value = $1.to_i
      else
         value = rand(DEFAULT_RAND_POINTS)
      end  
      if self.is_a?(Game_Actor)
         value /= 2 ; value = 1 if value < 1
         $game_system.bonus_gauge[0] -= value if DAMAGE_PENALTY
      else
         $game_system.bonus_gauge[0] += value 
      end
      check_gauge_limit ; active_bonus_gauge
  end

  #--------------------------------------------------------------------------
  # ● Active Bonus Gauge
  #--------------------------------------------------------------------------            
  def active_bonus_gauge
      return if $game_system.bonus_gauge[0] < 100
      $game_system.bonus_gauge[0] = 100
      $game_system.bonus_gauge[2] = rand(5)
      $game_system.bonus_gauge[3] = true
      $game_system.bonus_gauge[4] = 0      
      Audio.se_play("Audio/SE/" + SE_BONUS_ON,100,100)
  end
  
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler  

  #--------------------------------------------------------------------------
  # ● Drop Item Rate
  #--------------------------------------------------------------------------  
  def drop_item_rate
      $game_party.drop_item_double? or bonus_treasure? ? 2 : 1
  end
  
  #--------------------------------------------------------------------------
  # ● Bonus treasure
  #--------------------------------------------------------------------------    
  def bonus_treasure?
      $game_system.bonus_gauge[3] and $game_system.bonus_gauge[2] == 4
  end  
  
end  

#==============================================================================
# ■ Game_Troop
#==============================================================================
class Game_Troop < Game_Unit  
  
  #--------------------------------------------------------------------------
  # ● Exp Total
  #--------------------------------------------------------------------------
  def exp_total
      dead_members.inject(0) {|r, enemy| r += enemy.exp } * exp_rate
  end  
  
  #--------------------------------------------------------------------------
  # ● Exp Rate
  #--------------------------------------------------------------------------  
  def exp_rate
      bonus_exp? ? 2 : 1
  end
  
  #--------------------------------------------------------------------------
  # ● Bonus Exp
  #--------------------------------------------------------------------------  
  def bonus_exp?
      $game_system.bonus_gauge[3] and $game_system.bonus_gauge[2] == 2      
  end    
  
  #--------------------------------------------------------------------------
  # ● Gold Rate
  #--------------------------------------------------------------------------
  def gold_rate
      $game_party.gold_double? or bonus_gold? ? 2 : 1
  end
  
  #--------------------------------------------------------------------------
  # ● Bonus Gold
  #--------------------------------------------------------------------------  
  def bonus_gold?
      $game_system.bonus_gauge[3] and $game_system.bonus_gauge[2] == 3
  end   
  
end