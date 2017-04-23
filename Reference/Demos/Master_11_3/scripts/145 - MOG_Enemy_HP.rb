#==============================================================================
# +++ MOG - Enemy HP Meter  (v1.9) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Apresenta um medidor animado com o HP do inimigo.
#==============================================================================
# Para ocultar o HP do inimigo use a TAG abaixo na caixa de notas.
#
# <Hide HP>
#
#==============================================================================
# Serão necessários as imagens.
#
# Battle_Enemy_HP_Layout.png
# Battle_Enemy_HP_Meter.png
#
#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# (1.9) - Compatibilidade com o MOG Battle Camera.
# (1.8) - Melhoria da compatibilidade de scripts.
# (1.7) - Correção da posição do medidor de HP em algumas sistuações.
# (1.6) - Melhoria no sistema de posição da origem Z.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_enemy_hp] = true

module MOG_ENEMY_HP
   #Posição geral do medidor em relação ao battler.
   POSITION_CORRECTION = [0,0]
   #Posição do medidor de HP.
   HP_METER_POSITION = [3,13]
   #Apresentar o HP do inimigo na seleção do alvo.
   SHOW_ENEMY_HP_SELECTION = true
   #Prioridade do medidor na tela.
   PRIORITY_Z = 101
end

#==============================================================================
# ■ Game Enemy
#==============================================================================
class Game_Enemy < Game_Battler

  attr_accessor :hp_meter_active               
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_enemy_hp_initialize initialize
  def initialize(index, enemy_id)
      mog_enemy_hp_initialize(index, enemy_id)
      hide = enemy.note =~ /<Hide HP>/i ? true : false 
      @hp_meter_active = [false,hide]
  end  

end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # ● Item Apply
  #--------------------------------------------------------------------------  
   alias mog_enemy_hp_item_apply item_apply
   def item_apply(user, item)
       mog_enemy_hp_item_apply(user, item)
       self.hp_meter_active[0] = true if self.is_a?(Game_Enemy) and @result.hp_damage != 0   
   end

  #--------------------------------------------------------------------------
  # ● Regenerate HP
  #--------------------------------------------------------------------------
  alias mog_enemy_hp_regenerate_hp regenerate_hp
  def regenerate_hp
      mog_enemy_hp_regenerate_hp
      self.hp_meter_active[0] = true if self.is_a?(Game_Enemy) and @result.hp_damage != 0   
  end
    
end
  
#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  
  attr_accessor :cache_enemy_hp
  attr_accessor :battle_end
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------      
  alias mog_enemy_hp_initialize initialize
  def initialize
      @battle_end = false    
      mog_enemy_hp_initialize
      cache_ehp
  end
  
  #--------------------------------------------------------------------------
  # ● Cache EHP
  #--------------------------------------------------------------------------     
  def cache_ehp
      @cache_enemy_hp = []
      @cache_enemy_hp.push(Cache.system("Battle_Enemy_HP_Layout"))
      @cache_enemy_hp.push(Cache.system("Battle_Enemy_HP_Meter"))
  end
  
  #--------------------------------------------------------------------------
  # ● Sprite Visible
  #--------------------------------------------------------------------------    
  def sprite_visible
      return false if $game_message.visible
      return false if $game_temp.battle_end
      return true
  end 
  
end

#==============================================================================
# ■ Enemy HP
#==============================================================================
class Enemy_HP
  include MOG_ENEMY_HP
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  def initialize(viewport = nil,enemy,index)
      $game_temp.battle_end = false
      @enemy = enemy ; @index = index ; @fade_time = -1
      create_layout ; create_hp_meter      
      @layout.opacity = 0 ; @layout.visible = false
      @layout.viewport = viewport ; @hp_meter.opacity = 0
      @hp_meter.visible = false ; @hp_meter.viewport = viewport
      @layout.z = PRIORITY_Z ; @enemy.hp_meter_active[0] = false
      @enemy_old = @enemy ; @enemy_old2 = nil
      @hide = @enemy.hp_meter_active[1]
      set_meter_position ; @force_visbible = false
  end
  
  #--------------------------------------------------------------------------
  # ● Set Meter Position
  #--------------------------------------------------------------------------    
  def set_meter_position
      return if @enemy == nil
      b_pos = [@enemy.screen_x - (@layout.width / 2) + POSITION_CORRECTION[0],
               @enemy.screen_y + POSITION_CORRECTION[1] - (@layout.height / 2)]
      @org_pos1 = [b_pos[0],b_pos[1]]
      @layout.x = @org_pos1[0] ; @layout.y = @org_pos1[1]    
      @org_pos2 = [b_pos[0] + HP_METER_POSITION[0],
                   b_pos[1] + HP_METER_POSITION[1]]
      @hp_meter.x = @org_pos2[0] ; @hp_meter.y = @org_pos2[1]
      @hp_meter.z = PRIORITY_Z    
  end     
      
  #--------------------------------------------------------------------------
  # ● Create HP Meter
  #--------------------------------------------------------------------------        
  def create_layout
      @layout = Sprite.new ; @layout.bitmap = $game_temp.cache_enemy_hp[0]
  end
    
  #--------------------------------------------------------------------------
  # ● Create HP Meter
  #--------------------------------------------------------------------------      
  def create_hp_meter
      @meter_image = $game_temp.cache_enemy_hp[1]
      @meter_cw = @meter_image.width ; @meter_ch = @meter_image.height / 2       
      @hp_meter = Sprite.new
      @hp_meter.bitmap = Bitmap.new(@meter_cw,@meter_ch)
      @hp_width_old = @meter_cw * @enemy.hp / @enemy.mhp 
    end  
  
  #--------------------------------------------------------------------------
  # ● Hp Flow Update
  #--------------------------------------------------------------------------
  def update_hp_flow
      return if !@layout.visible     
      hp_width = @meter_cw * @enemy.hp / @enemy.mhp
      @hp_meter.bitmap.clear ; execute_damage_flow(hp_width)
      hp_src_rect = Rect.new(0,0,hp_width, @meter_ch)
      @hp_meter.bitmap.blt(0,0, @meter_image, hp_src_rect)
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Damage Flow
  #-------------------------------------------------------------------------- 
  def execute_damage_flow(hp_width)
      n = (@hp_width_old - hp_width).abs * 3 / 100
      damage_flow = [[n, 2].min,0.5].max
      @hp_width_old -= damage_flow
      @hp_width_old = hp_width if @hp_width_old <= hp_width 
      src_rect_old = Rect.new(0,@meter_ch,@hp_width_old, @meter_ch)
      @hp_meter.bitmap.blt(0,0, @meter_image, src_rect_old)       
  end    
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------      
  def dispose
      return if @layout == nil
      @layout.dispose ; @hp_meter.bitmap.dispose ; @hp_meter.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------      
  def update
      return if @meter_image == nil
      return if @hide
      if force_hide_enemy_hp?
         @hp_meter.visible = false
         @layout.visible = false   
         return
      end
      update_clear ; update_fade ; update_visible
      update_hp_flow ; refresh if @enemy.hp_meter_active[0]
      update_battle_camera if $imported[:mog_battle_camera]
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Battle Camera
  #--------------------------------------------------------------------------               
  def update_battle_camera
      @hp_meter.ox = $game_temp.viewport_oxy[0]
      @hp_meter.oy = $game_temp.viewport_oxy[1]
      @layout.ox = $game_temp.viewport_oxy[0]
      @layout.oy = $game_temp.viewport_oxy[1]
  end  
  
  #--------------------------------------------------------------------------
  # ● Force Hide Enemy HP
  #--------------------------------------------------------------------------      
  def force_hide_enemy_hp?
      if $imported[:mog_atb_system]
         return true if $game_temp.atb_user == nil
         return true if $game_temp.end_phase_duration[1] > 0
      end
      return true if !$game_temp.sprite_visible
      return true if $game_message.visible
      return true if $game_temp.battle_end
      return false
  end         
  
  #--------------------------------------------------------------------------
  # ● Can Update Force Refresh
  #--------------------------------------------------------------------------      
  def can_update_force_refresh?
      return false if @index != 0
      return false if !SHOW_ENEMY_HP_SELECTION
      return false if $imported[:mog_battle_cursor] == nil
      return false if $game_temp.battle_cursor_data == nil
      @force_visbible = true ; force_refresh if can_force_refresh?
      return true
  end
    
  #--------------------------------------------------------------------------
  # ● Update force_refresh
  #--------------------------------------------------------------------------        
  def can_force_refresh?
      return false if @enemy_old2 == $game_temp.battle_cursor_data
      return false if $game_temp.battle_cursor_data.is_a?(Game_Actor)
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Update clear
  #--------------------------------------------------------------------------        
  def update_clear
      return if !@force_visbible
      @force_visbible = false ; @enemy = @enemy_old ; @enemy_old2 = nil
      @layout.visible = false ;  @hp_meter.visible = false         
  end
    
  #--------------------------------------------------------------------------
  # ● Update Fade
  #--------------------------------------------------------------------------        
  def update_fade
      @fade_time -= 1 if @fade_time > 0
      return if @fade_time != 0 
      @layout.opacity -= 10 ; @hp_meter.opacity -= 10
      @layout.x += 1 ; @hp_meter.x += 1 ; @fade_time = -1 if @layout.opacity == 0
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Visible
  #--------------------------------------------------------------------------        
  def update_visible 
      return if !@layout.visible 
      vis = can_visible? ; @layout.visible = vis ; @hp_meter.visible = vis
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------          
  def refresh
      set_meter_position
      @enemy.hp_meter_active[0] = false ; @fade_time = 60
      @layout.opacity = 255  ; @hp_meter.opacity = 255    
      @layout.visible = true ; @hp_meter.visible = true
      @layout.x = @org_pos1[0] ;  @layout.y = @org_pos1[1]
      @hp_meter.x = @org_pos2[0]; @hp_meter.y = @org_pos2[1]      
      hp_width = @meter_cw * @enemy.hp / @enemy.mhp 
      @hp_width_old = hp_width if @hp_width_old < hp_width
      update_hp_flow      
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------          
  def force_refresh
      return if $game_temp.battle_cursor_data == nil
      @enemy_old2 = $game_temp.battle_cursor_data
      @enemy = $game_temp.battle_cursor_data
      set_meter_position
      @enemy.hp_meter_active[0] = false ; @fade_time = 2
      @layout.opacity = 255 ;  @hp_meter.opacity = 255    
      @layout.visible = true ; @hp_meter.visible = true
      @layout.x = @org_pos1[0] ;  @layout.y = @org_pos1[1]
      @hp_meter.x = @org_pos2[0]; @hp_meter.y = @org_pos2[1]       
      hp_width = @meter_cw * @enemy.hp / @enemy.mhp 
      @hp_width_old = hp_width ; update_hp_flow
  end  
  
  #--------------------------------------------------------------------------
  # ● Can Visible?
  #--------------------------------------------------------------------------          
  def can_visible?
      return false if @layout.opacity == 0
      return false if $game_message.visible
      return false if $game_temp.battle_end       
      return true
  end
    
end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_enemy_hp_initialize initialize
  def initialize
      mog_enemy_hp_initialize
      create_enemy_hp
  end
  
  #--------------------------------------------------------------------------
  # ● Create Battle Hud
  #--------------------------------------------------------------------------    
  def create_enemy_hp
      @enemy_hp = []      
      $game_troop.members.each_with_index do |i, index| @enemy_hp.push(Enemy_HP.new(nil,i,index)) end
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------      
  alias mog_enemy_hp_dispose dispose
  def dispose
      dispose_enemy_hp
      mog_enemy_hp_dispose
  end  
  
  #--------------------------------------------------------------------------
  # ● Dispose Enemy HP
  #--------------------------------------------------------------------------        
  def dispose_enemy_hp
      return if @enemy_hp == nil
      @enemy_hp.each {|sprite| sprite.dispose } ; @enemy_hp.clear
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------        
  alias mog_enemy_hp_update update
  def update
      mog_enemy_hp_update
      update_enemy_hp
  end
  
  #--------------------------------------------------------------------------
  # ● Update Enemy HP
  #--------------------------------------------------------------------------          
  def update_enemy_hp
      return if @enemy_hp == nil
      @enemy_hp.each {|sprite| sprite.update }
  end
   
end