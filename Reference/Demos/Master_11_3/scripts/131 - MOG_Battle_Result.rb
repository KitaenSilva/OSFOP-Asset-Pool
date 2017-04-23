#==============================================================================
# +++ MOG - Battle Result (2.0) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# Apresentação animada do resultado da batalha.
#==============================================================================
# Arquivos necessários. (Graphics/System)
# 
# Result.png
# Result_Layout.png
# Result_Levelup.png
# Result_Levelword.png
# Result_Number_1.png
# Result_Number_2.png
#
#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v2.0 - Correção do bug de não ativar o resultado em inimigos ocultos.
#==============================================================================
module MOG_BATLE_RESULT
  #Posição do EXP.
  RESULT_EXP_POSITION = [440,80]
  #Posição do GOLD.
  RESULT_GOLD_POSITION = [476,125]
  #Posição da palavra LeveL UP.
  RESULT_LEVELWORD_POSITION = [0,0]
  #Posição do Level.
  RESULT_LEVEL_POSITION = [230,-7]
  #Posição dos parâmetros
  RESULT_PARAMETER_POSITION = [70,70]
  #Posição da janela de skill.
  RESULT_NEW_SKILL_POSITION = [240,230]
  #Definição da animação de Level UP.
  RESULT_LEVELUP_ANIMATION_ID = 37
end 

$imported = {} if $imported.nil?
$imported[:mog_battler_result] = true

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  attr_accessor :level_parameter
  attr_accessor :level_parameter_old
  attr_accessor :result
  attr_accessor :battle_end
  attr_accessor :battle_result
   
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_result_initialize initialize
  def initialize
      @level_parameter = [] ; @level_parameter_old = []
      @result = false ; @battle_end = false ; @battle_result = false
      mog_result_initialize
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
# ■ Game Actor
#==============================================================================
class Game_Actor < Game_Battler

  #--------------------------------------------------------------------------
  # ● Display_level_up
  #--------------------------------------------------------------------------
  alias mog_result_display_level_up display_level_up
  def display_level_up(new_skills)
      if $game_temp.result
         $game_temp.level_parameter = [@level,new_skills]
         return 
      end    
      mog_result_display_level_up(new_skills)
  end

end

#==============================================================================
# ■ BattleManager
#==============================================================================
module BattleManager
  
  #--------------------------------------------------------------------------
  # ● Process Victory
  #--------------------------------------------------------------------------
  def self.process_victory
      @phase = nil
      @event_proc.call(0) if @event_proc
      $game_temp.battle_result = true ;play_battle_end_me ; replay_bgm_and_bgs
      SceneManager.return
      return true
  end
  
end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------                
  alias mog_battle_result_pre_terminate pre_terminate
  def pre_terminate
      execute_result if can_enable_battle_result?
      mog_battle_result_pre_terminate
  end  
  
  #--------------------------------------------------------------------------
  # ● Can Enable Battle Result?
  #--------------------------------------------------------------------------   
  def can_enable_battle_result?
      return false if !$game_temp.battle_result
      return true
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Result
  #--------------------------------------------------------------------------                  
  def execute_result
      $game_temp.battle_result = false
      result = Battle_Result.new
      $game_temp.combo_hit[2] = 0 rescue nil if $imported[:mog_combo_count]
      @status_window.visible = false
      if $imported[:mog_battle_command_ex]
         @window_actor_face.visible = false if @window_actor_face != nil
      end
      loop do 
           result.update ; @spriteset.update
           Graphics.update ; Input.update
           break if result.victory_phase == 10
      end
      result.dispose
      $game_party.on_battle_end
      $game_troop.on_battle_end
      SceneManager.exit if $BTEST
  end  
  
end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result
  include MOG_BATLE_RESULT
  
  attr_accessor :victory_phase
    
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------      
  def initialize
      $game_temp.battle_end = true ; $game_temp.result = true
      @victory_phase = 0 ; @victory_wait_duration = 0
      @fade_result_window = false ; create_victory_sprites 
  end 
  
  #--------------------------------------------------------------------------
  # ● Create Victory Sprites
  #--------------------------------------------------------------------------    
  def create_victory_sprites
      @result_number = Cache.system("Result_Number_1")
      @result_number2 = Cache.system("Result_Number_2")
      @result_cw = @result_number.width / 10
      @result_ch = @result_number.height / 2          
      @result2_cw = @result_number2.width / 10
      @result2_ch = @result_number2.height / 2  
      create_victory_text ; create_victory_layout ; create_victory_exp
      create_victory_gold ; create_window_treasure
  end  

  #--------------------------------------------------------------------------
  # ● Victory Wait ?
  #--------------------------------------------------------------------------        
  def victory_wait?
      return false if @victory_wait_duration <= 0
      @victory_wait_duration -= 1 
      return true
  end     
  
  #--------------------------------------------------------------------------
  # ● End Victory
  #--------------------------------------------------------------------------    
  def end_victory
      @victory_wait_duration = 10 ; dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Create Victory Layout
  #--------------------------------------------------------------------------      
  def create_victory_layout
      return if @victory_layout_sprite != nil
      @victory_layout_sprite = Sprite.new
      @victory_layout_sprite.z = 1001
      @victory_layout_sprite.bitmap = Cache.system("Result_Layout")
      @victory_layout_sprite.zoom_x = 2.0
      @victory_layout_sprite.opacity = 0
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Victory Text
  #--------------------------------------------------------------------------      
  def create_victory_text
      return if @victory_sprite != nil
      @victory_sprite = Sprite.new
      @victory_sprite.z = 1000
      @victory_sprite.bitmap = Cache.system("Result")
      @victory_sprite.ox = @victory_sprite.width / 2
      @victory_sprite.oy = @victory_sprite.height / 2
      @victory_sprite.x = @victory_sprite.ox
      @victory_sprite.y = @victory_sprite.oy
      @victory_sprite.zoom_x = 1.5
      @victory_sprite.zoom_y = 1.5
      @victory_sprite.opacity = 0    
  end  
  
end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------      
  def dispose
      $game_temp.result = false
      @victory_sprite.bitmap.dispose ; @victory_sprite.dispose
      @victory_layout_sprite.bitmap.dispose ; @victory_layout_sprite.dispose
      @exp_number.bitmap.dispose ; @exp_number.dispose
      @gold_number.bitmap.dispose ; @gold_number.dispose
      @result_number.dispose ; @window_treasure.dispose
      dispose_level_up ; @result_number.dispose ; @result_number2.dispose
      @tr_viewport.dispose
  end  
    
  #--------------------------------------------------------------------------
  # ● Dispose Result Actor Bitmap
  #--------------------------------------------------------------------------              
  def dispose_result_actor_bitmap
      return if @result_actor_sprite == nil
      return if @result_actor_sprite.bitmap == nil
      @result_actor_sprite.bitmap.dispose
  end 
  
  #--------------------------------------------------------------------------
  # ● Dispose Level UP
  #--------------------------------------------------------------------------        
  def dispose_level_up
      return if @levelup_layout == nil
      @levelup_layout.bitmap.dispose ; @levelup_layout.dispose
      @levelup_word.bitmap.dispose ; @levelup_word.dispose
      @result_actor_sprite.bitmap.dispose ; @result_actor_sprite.dispose
      @parameter_sprite.bitmap.dispose ; @parameter_sprite.dispose
      @level_sprite.bitmap.dispose ; @level_sprite.dispose
      @new_skill_window.dispose if @new_skill_window
  end
  
end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  def update
      $game_temp.battle_end = true
      if $mog_rgss3_pause != nil
         update_pause if MOG_PAUSE::PAUSE_SCENE_BATTLE
      end    
      return if @victory_phase == nil
      update_victory_fade if @fade_result_window
      return if victory_wait?
      case @victory_phase
         when 0;  update_victory_initial
         when 1;  update_victory_initial2
         when 2;  update_victory_initial3
         when 3;  update_victory_exp
         when 4;  update_victory_gold
         when 5;  update_victory_item
         when 6;  update_victory_levelup
         when 9;  update_skip_result
      end
      if Input.trigger?(:C)
         if @victory_phase == 10
            end_victory
         elsif @victory_phase.between?(1,5)
            Sound.play_cursor ; @victory_phase = 9
         end          
      end   
  end
  
  #--------------------------------------------------------------------------
  # ● Skip Result
  #--------------------------------------------------------------------------         
  def update_skip_result
      @victory_sprite.opacity -= 10
      @victory_sprite.visible = false
      @victory_layout_sprite.opacity += 10
      @victory_layout_sprite.zoom_x = 1.00
      @gold_number.opacity += 10
      @gold_number.zoom_x = 1.00
      @gold_number.zoom_y = 1.00
      @exp_number.opacity += 10
      @exp_number.zoom_x = 1.00
      @exp_number.zoom_y = 1.00      
      @window_treasure.contents_opacity += 10
      if @exp_old != @exp_total
         @exp_old = @exp_total 
         refresh_exp_number
      end
      if @gold_old = @gold_total  
         @gold_old = @gold_total 
         refresh_gold_number
      end   
      @window_treasure.x = 0
      update_victory_item if @window_treasure.contents_opacity == 255
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Victory Fade
  #--------------------------------------------------------------------------       
  def update_victory_fade
      fade_speed = 10
      @victory_sprite.opacity -= fade_speed
      @victory_layout_sprite.opacity -= fade_speed
      @gold_number.opacity -= fade_speed
      @exp_number.opacity -= fade_speed
      @window_treasure.contents_opacity -= fade_speed
  end
  
  #--------------------------------------------------------------------------
  # ● Update Victory Initial
  #--------------------------------------------------------------------------      
  def update_victory_initial
      @victory_sprite.zoom_x -= 0.01
      @victory_sprite.zoom_y -= 0.01
      @victory_sprite.opacity += 10
      if @victory_sprite.zoom_x <= 1.00
         @victory_sprite.zoom_x = 1
         @victory_sprite.zoom_y = 1
         @victory_sprite.opacity = 255
         @victory_phase = 1
         @victory_wait_duration = 20
      end
  end

  #--------------------------------------------------------------------------
  # ● Update Victory Initial 2
  #--------------------------------------------------------------------------      
  def update_victory_initial2
      @victory_sprite.zoom_x += 0.01
      @victory_sprite.zoom_y += 0.01
      @victory_sprite.opacity -= 10
      if @victory_sprite.opacity <= 0
         @victory_sprite.zoom_x = 1
         @victory_sprite.zoom_y = 1
         @victory_sprite.opacity = 0
         @victory_phase = 2
      end
  end

  #--------------------------------------------------------------------------
  # ● Update Victory Initial 3
  #--------------------------------------------------------------------------        
  def update_victory_initial3    
      @victory_layout_sprite.zoom_x -= 0.02
      @victory_layout_sprite.opacity += 10
      if @victory_layout_sprite.zoom_x <= 1.00
         @victory_layout_sprite.zoom_x = 1
         @victory_layout_sprite.opacity = 255
         @victory_phase = 3
      end              
  end    
      
end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result

  #--------------------------------------------------------------------------
  # ● Create Victory Exp
  #--------------------------------------------------------------------------      
  def create_victory_exp
      @exp_number = Sprite.new
      @exp_number.bitmap = Bitmap.new(@result_number.width,@result_ch)
      @exp_number.z = 1002 ; @exp_number.y = RESULT_EXP_POSITION[1]
      @exp_number.zoom_x = 2 ; @exp_number.zoom_y = 2
      @exp_total = $game_troop.exp_total ; @exp_number.opacity = 0
      @exp_old = 0
      @exp_ref = ((1 * @exp_total) / 111).truncate rescue nil
      @exp_ref = 1 if @exp_ref < 1 or @exp_ref == nil      
      @exp_ref = 0 if @exp_total == 0
      refresh_exp_number
  end
  
  #--------------------------------------------------------------------------
  # ● Update Victory Exp
  #--------------------------------------------------------------------------        
  def update_victory_exp
      update_exp_sprite ; update_exp_number
  end
  
  #--------------------------------------------------------------------------
  # ● Update EXP Sprite
  #--------------------------------------------------------------------------          
  def update_exp_sprite
      @exp_number.opacity += 15
      if @exp_number.zoom_x > 1.00
         @exp_number.zoom_x -= 0.03
         @exp_number.zoom_x = 1.00 if @exp_number.zoom_x <= 1.00
      end
      @exp_number.zoom_y = @exp_number.zoom_x
      if (@exp_old >= @exp_total) and @exp_number.zoom_x == 1.00
         @victory_phase = 4
         Sound.play_cursor
      end   
  end

  #--------------------------------------------------------------------------
  # ● Refresh Exp Number
  #--------------------------------------------------------------------------        
  def refresh_exp_number
      @exp_number.bitmap.clear
      draw_result_exp(@exp_old, 0,0)      
  end

  #--------------------------------------------------------------------------
  # ● Update Exp_number
  #--------------------------------------------------------------------------
  def update_exp_number
      return if @exp_old == @exp_total 
      @exp_old += @exp_ref
      @exp_old = @exp_total if @exp_old > @exp_total
      refresh_exp_number
  end

  #--------------------------------------------------------------------------
  # ● Draw Result EXP
  #--------------------------------------------------------------------------        
  def draw_result_exp(value,x,y)
      ncw = @result_cw ; nch = @result_ch ; number = value.abs.to_s.split(//)
      x2 = x - (number.size * ncw)
      @exp_number.ox = (number.size * ncw) / 2
      @exp_number.oy = @result_ch / 2
      @exp_number.x = (RESULT_EXP_POSITION[0] + @result_cw + @exp_number.ox) - (number.size * ncw)
      for r in 0..number.size - 1
          number_abs = number[r].to_i
          nsrc_rect = Rect.new(ncw * number_abs, 0, ncw, nch)
          @exp_number.bitmap.blt(x + (ncw *  r), y, @result_number, nsrc_rect)        
      end
  end

end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result

  #--------------------------------------------------------------------------
  # ● Create Victory Gold
  #--------------------------------------------------------------------------      
  def create_victory_gold
      @gold_number = Sprite.new
      @gold_number.bitmap = Bitmap.new(@result_number.width,@result_ch)
      @gold_number.z = 1002
      @gold_number.y = RESULT_GOLD_POSITION[1]
      @gold_number.opacity = 0 
      @gold_number.zoom_x = 2 
      @gold_number.zoom_y = 2      
      @gold_total = $game_troop.gold_total
      @gold_old = 0
      @gold_ref = ((1 * @gold_total) / 111).truncate rescue nil
      @gold_ref = 1 if @gold_ref < 1 or @gold_ref == nil      
      @gold_ref = 0 if @gold_total == 0
      $game_party.gain_gold($game_troop.gold_total)
      refresh_gold_number
  end   
  
  #--------------------------------------------------------------------------
  # ● Update Victory Gold
  #--------------------------------------------------------------------------        
  def update_victory_gold
      update_gold_sprite ; update_gold_number
  end
  
  #--------------------------------------------------------------------------
  # ● Update GOLD Sprite
  #--------------------------------------------------------------------------          
  def update_gold_sprite
      @gold_number.opacity += 15
      if @gold_number.zoom_x > 1.00
         @gold_number.zoom_x -= 0.03
         @gold_number.zoom_x = 1.00 if @gold_number.zoom_x <= 1.00
      end
      @gold_number.zoom_y = @gold_number.zoom_x 
      if @gold_old >= @gold_total and @gold_number.zoom_x == 1.00
         @victory_phase = 5 ; Sound.play_cursor 
      end   
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh gold Number
  #--------------------------------------------------------------------------        
  def refresh_gold_number
      @gold_number.bitmap.clear
      draw_result_gold(@gold_old, 0,0)      
  end
  
  #--------------------------------------------------------------------------
  # ● Update Gold Number
  #--------------------------------------------------------------------------
  def update_gold_number 
      return if @gold_old == @gold_total 
      @gold_old += @gold_ref
      @gold_old = @gold_total if @gold_old > @gold_total 
      refresh_gold_number
  end       
  
  #--------------------------------------------------------------------------
  # ● Draw Result Gold
  #--------------------------------------------------------------------------        
  def draw_result_gold(value,x,y)
      ncw = @result_cw ; nch = @result_ch
      number = value.abs.to_s.split(//)
      x2 = x - (number.size * ncw)
      @gold_number.ox = (number.size * ncw) / 2
      @gold_number.oy = @result_ch / 2
      @gold_number.x = (RESULT_GOLD_POSITION[0] + @result_cw + @gold_number.ox) - (number.size * ncw)
      for r in 0..number.size - 1
          number_abs = number[r].to_i
          nsrc_rect = Rect.new(ncw * number_abs, @result_ch, ncw, nch)
          @gold_number.bitmap.blt(x + (ncw *  r), y, @result_number, nsrc_rect)        
      end
  end
 
end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result
  
  #--------------------------------------------------------------------------
  # ● Create Window Treasure
  #--------------------------------------------------------------------------            
  def create_window_treasure
      @tr_viewport = Viewport.new(-8, 164, Graphics.width + 32, 118)
      @tr_viewport.z = 1003
      @window_treasure = Window_Treasure.new
      @window_treasure.viewport = @tr_viewport
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Victory Item
  #--------------------------------------------------------------------------          
  def update_victory_item
      @window_treasure.update
      @actor_level = []
      return if @window_treasure.x != 0 and @victory_phase >= 6
      @victory_phase = 6
      if $data_system.opt_extra_exp
         @result_member_max = $game_party.members.size 
      else
         @result_member_max = $game_party.battle_members.size
      end
      @result_member_id = 0
  end
  
end

#==============================================================================
# ■ Window Treasure
#==============================================================================
class Window_Treasure < Window_Base
 
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
      super(-Graphics.width,-10, Graphics.width + 32, 288)
      self.opacity = 0 ; self.contents_opacity = 0 
      self.contents.font.size = 24 ; self.contents.font.bold = true
      self.z = 1003 ; @range_max = 256 ; @wait_time = 30 ; @scroll = false
      draw_treasure
  end

  #--------------------------------------------------------------------------
  # ● Draw_Treasure
  #--------------------------------------------------------------------------  
  def draw_treasure
      contents.clear
      space_x = Graphics.width / 3
      $game_troop.make_drop_items.each_with_index do |item, index|
         xi = (index * space_x) - ((index / 3) * (space_x * 3))        
         yi = (index / 3) * 32
         $game_party.gain_item(item, 1)
         draw_item_name(item,xi, yi, true, 140)
     end
     @range_max = ($game_troop.make_drop_items.size / 3) * 32
     @scroll = true if $game_troop.make_drop_items.size > 12
  end  
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  def update
      super
      self.contents_opacity += 10
      if self.x < 0
         self.x += 15
        (self.x = 0 ; Sound.play_cursor) if self.x >= 0
      end
      if @scroll and self.contents_opacity == 255 and self.x == 0
         @wait_time -= 1 if  @wait_time > 0
         return if @wait_time > 0
         self.y -= 1
         self.y = 128 if self.y < -@range_max
         @wait_time = 30 if self.y == -10
      end
  end

end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result
  
  #--------------------------------------------------------------------------
  # ● Create Levelup
  #--------------------------------------------------------------------------            
  def create_levelup
      if @levelup_layout == nil
         @levelup_layout = Sprite.new ; @levelup_layout.z = 1000
         @levelup_layout.bitmap = Cache.system("Result_Levelup")
      end
      if @levelup_word == nil
         @levelup_word = Sprite.new ; @levelup_word.z = 1001
         @levelup_word.bitmap = Cache.system("Result_Levelword")
         @levelup_word.ox = @levelup_word.bitmap.width / 2
         @levelup_word.oy = @levelup_word.bitmap.height / 2
         @levelup_word.x = @levelup_word.ox + RESULT_LEVELWORD_POSITION[0]
         @levelup_word.y = @levelup_word.oy + RESULT_LEVELWORD_POSITION[1]
      end
      @levelup_word.blend_type = 1
      @levelup_word.zoom_x = 2 ; @levelup_word.zoom_y = 2       
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Parameter Number
  #--------------------------------------------------------------------------              
  def create_parameter_number
      if @parameter_sprite == nil
         @parameter_sprite = Sprite.new
         @parameter_sprite.bitmap = Bitmap.new(250,220)
         @parameter_sprite.z = 1001
         @parameter_sprite.x = RESULT_PARAMETER_POSITION[0]
         @parameter_sprite.y = RESULT_PARAMETER_POSITION[1]
         @parameter_sprite.bitmap.font.size = 16
         @parameter_sprite.bitmap.font.bold = true         
      end
      refresh_parameter 
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh Parameter
  #--------------------------------------------------------------------------                
  def refresh_parameter
       @parameter_animation = 0
       @parameter_sprite.bitmap.clear
       @parameter_sprite.opacity = 0
       @parameter_sprite.x = RESULT_PARAMETER_POSITION[0] - 200
       actor_old = $game_temp.level_parameter_old
       draw_result_parameter(@actor_result.mhp,actor_old[1],0,28 * 0)
       draw_result_parameter(@actor_result.mmp,actor_old[2],0,28 * 1)
       draw_result_parameter(@actor_result.atk,actor_old[3],0,28 * 2)
       draw_result_parameter(@actor_result.def,actor_old[4],0,28 * 3)
       draw_result_parameter(@actor_result.mat,actor_old[5],0,28 * 4)
       draw_result_parameter(@actor_result.mdf,actor_old[6],0,28 * 5)
       draw_result_parameter(@actor_result.agi,actor_old[7],0,28 * 6)
       draw_result_parameter(@actor_result.luk,actor_old[8],0,28 * 7)
  end  
  
  #--------------------------------------------------------------------------
  # ● Draw Result EXP
  #--------------------------------------------------------------------------        
  def draw_result_parameter(value,value2,x,y)
      ncw = @result2_cw ; nch = @result2_ch ; number = value.abs.to_s.split(//)
      x2 = x + (number.size * ncw) + 16
      for r in 0..number.size - 1
          number_abs = number[r].to_i
          nsrc_rect = Rect.new(ncw * number_abs, 0, ncw, nch)
          @parameter_sprite.bitmap.blt(x + (ncw *  r), y, @result_number2, nsrc_rect)        
      end
      value3 = value - value2
      par = ""
      if value > value2
         par = "+"
         @parameter_sprite.bitmap.font.color = Color.new(50,255,255)
      elsif value < value2
         par = ""
         @parameter_sprite.bitmap.font.color = Color.new(255,155,100)
      end
      return if value == value2
      @parameter_sprite.bitmap.draw_text(x2,y - 8,100,32,par.to_s + value3.to_s,0)   
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Result Actor
  #--------------------------------------------------------------------------            
  def create_result_actor
      if @result_actor_sprite == nil
         @result_actor_sprite = Sprite.new ; @result_actor_sprite.z = 999
      end
      dispose_result_actor_bitmap
      @result_actor_sprite.bitmap = Cache.picture("Actor" + @actor_result.id.to_s)
      @result_actor_org = [380 - (@result_actor_sprite.bitmap.width / 2), Graphics.height - @result_actor_sprite.bitmap.height]
      @result_actor_sprite.x = @result_actor_org[0] + 200
      @result_actor_sprite.y = @result_actor_org[1]
      @result_actor_sprite.opacity = 0
  end  
 
  #--------------------------------------------------------------------------
  # ● Check New Skill
  #--------------------------------------------------------------------------              
  def check_new_skill 
      @new_skills = $game_temp.level_parameter[1] ; @new_skills_index = 0
  end
     
  #--------------------------------------------------------------------------
  # ● Show New Skill
  #--------------------------------------------------------------------------                
  def show_new_skill(start = false)
      Sound.play_recovery unless start
      @new_skill_window.draw_new_skill(@new_skills[@new_skills_index])
      @new_skills_index += 1
      if @new_skills_index == @new_skills.size or 
         @new_skills[@new_skills_index] == nil
         @new_skills = nil 
      end   
  end
  
  #--------------------------------------------------------------------------
  # ● Check Level UP
  #--------------------------------------------------------------------------            
  def check_level_up    
      if @new_skills != nil and !@new_skills.empty?
         show_new_skill 
         return
       end  
      for battler_id in @result_member_id..@result_member_max
          actor_result = $game_party.members[@result_member_id]  
          $game_temp.level_parameter = []
          $game_temp.level_parameter_old = []
          $game_temp.level_parameter_old = [actor_result.level,actor_result.mhp,actor_result.mmp,
          actor_result.atk, actor_result.def, actor_result.mat, actor_result.mdf, actor_result.agi, actor_result.luk] rescue nil
          actor_result.gain_exp($game_troop.exp_total) rescue nil
          @result_member_id += 1 ; @new_skills = nil ; @new_skills_index = 0
          if @result_member_id > $game_party.battle_members.size
             $game_temp.level_parameter = [] 
             $game_temp.level_parameter_old = []
             next
          end
          if $game_temp.level_parameter != nil and !$game_temp.level_parameter.empty?
             show_level_result
             break
          end   
      end
      return if !$game_temp.level_parameter.empty?
      @victory_phase = 10 if @result_member_id >= @result_member_max
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Level
  #--------------------------------------------------------------------------                
  def create_level
      if @level_sprite == nil
         @level_sprite = Sprite.new ; @level_sprite.bitmap = Bitmap.new(200,64)
         @level_sprite.z = 1002
      end      
      @level_sprite.bitmap.font.size = 48
      @level_sprite.bitmap.font.bold = true
      @level_sprite.x = RESULT_LEVEL_POSITION[0]
      @level_sprite.y = RESULT_LEVEL_POSITION[1]
      @level_sprite.bitmap.clear
      @level_sprite.bitmap.font.color = Color.new(255,255,255)
      @level_sprite.bitmap.draw_text(0,0,100,64,@actor_result.level,1)
      levelup = @actor_result.level - $game_temp.level_parameter_old[0]
      @level_sprite.bitmap.font.color = Color.new(50,255,255)
      @level_sprite.bitmap.font.size = 18
      @level_sprite.bitmap.draw_text(80,0,100,64,"+" + levelup.to_s ,0)
  end
  
  #--------------------------------------------------------------------------
  # ● Create New Skill Windos
  #--------------------------------------------------------------------------                  
  def create_new_skill_window
      @new_skill_window = Window_Result_Skill.new if @new_skill_window == nil
      @new_skill_window.x = RESULT_NEW_SKILL_POSITION[0]
      @new_skill_window.y = RESULT_NEW_SKILL_POSITION[1]
      check_new_skill
      if @new_skills != nil and !@new_skills.empty?
         show_new_skill
      else  
         @new_skill_window.x = -Graphics.width
      end 
  end  
  
  #--------------------------------------------------------------------------
  # ● Show Level Result
  #--------------------------------------------------------------------------              
  def show_level_result
      Sound.play_cursor
      @actor_result = $game_party.members[@result_member_id - 1] rescue nil
      return if @actor_result == nil
      @actor_result.animation_id = RESULT_LEVELUP_ANIMATION_ID
      @fade_result_window = true
      create_levelup ; create_level ; create_parameter_number
      create_result_actor ; create_new_skill_window
  end  
  
end

#==============================================================================
# ■ Battle Result
#==============================================================================
class Battle_Result
  
  #--------------------------------------------------------------------------
  # ● Update Victory Item
  #--------------------------------------------------------------------------          
  def update_victory_levelup      
       check_level_up if Input.trigger?(:C)
       update_show_levelup
       if @levelup_layout == nil
          @window_treasure.update
       else
          @window_treasure.contents_opacity -= 15
       end
  end
  
  #--------------------------------------------------------------------------
  # ● Update Show Level UP
  #--------------------------------------------------------------------------            
  def update_show_levelup
      return if @levelup_layout == nil
      return if @result_actor_sprite == nil
      @new_skill_window.update
      if @result_actor_sprite.x > @result_actor_org[0]
         @result_actor_sprite.x -= 5
         @result_actor_sprite.opacity += 7
         if @result_actor_sprite.x <= @result_actor_org[0]
            @result_actor_sprite.x = @result_actor_org[0]
            @result_actor_sprite.opacity = 255
         end
      end
      if @levelup_word.zoom_x > 1.00
         @levelup_word.zoom_x -= 0.03
         if @levelup_word.zoom_x < 1.00
            @levelup_word.zoom_x = 1.00 ; @levelup_word.blend_type = 0
         end
      end
      @levelup_word.zoom_y = @levelup_word.zoom_x 
      if @parameter_sprite.x < RESULT_PARAMETER_POSITION[0]
         @parameter_sprite.opacity += 13
         @parameter_sprite.x += 5
         if @parameter_sprite.x >= RESULT_PARAMETER_POSITION[0]
            @parameter_sprite.opacity = 255
            @parameter_sprite.x = RESULT_PARAMETER_POSITION[0]
         end   
      end  
  end    
  
end

#==============================================================================
# ■ Window Result Skill
#==============================================================================
class Window_Result_Skill < Window_Base

  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
      super(0,0, 270, 58)
      self.opacity = 160 ; self.contents_opacity = 255 
      self.contents.font.bold = true ; self.z = 1003 ; @animation_time = 999
      @org = [MOG_BATLE_RESULT::RESULT_NEW_SKILL_POSITION[0],MOG_BATLE_RESULT::RESULT_NEW_SKILL_POSITION[1]]
  end

  #--------------------------------------------------------------------------
  # ● DrawNew Skill
  #--------------------------------------------------------------------------  
  def draw_new_skill(skill)
      contents.clear
      self.contents.font.size = 16
      self.contents.font.color = Color.new(100,200,100)
      contents.draw_text(0,0,100,32, "New Skill",0)
      self.contents.font.color = Color.new(255,255,255)
      draw_item_name_skill(skill,70,0, true, 170)
      self.x = @org[0] ; self.y = @org[1]
      @animation_time = 0 ; self.opacity = 0 ; self.contents_opacity = 0      
  end  
  
  #--------------------------------------------------------------------------
  # ● Draw Item Name
  #--------------------------------------------------------------------------
  def draw_item_name_skill(item, x, y, enabled = true, width = 172)
      return unless item
      draw_icon(item.icon_index, x, y, enabled)
      change_color(normal_color, enabled)
      draw_text(x + 24, y + 4, width, line_height, item.name)
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  def update
      super
      return if @animation_time == 999  
      @animation_time += 1 if @animation_time != 999
      case @animation_time
          when 0..30
            self.y -= 1 ; self.opacity += 5 ; self.contents_opacity += 5                  
          when 31..60
            self.y += 1 ; self.opacity += 5 ; self.contents_opacity += 5                     
          else
            self.y = @org[1] ; self.opacity = 255 ; self.contents_opacity = 255
            @animation_time = 999      
      end
  end  
    
end