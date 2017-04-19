#==============================================================================
# +++ MOG - Combo Count (v1.7) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Apresenta a quantidade de acertos no alvo e o dano maximo.
#==============================================================================
# É necessário ter os arquivos imagens na pasta Graphics/Systems.
# Combo_Damage.png 
# Combo_Hud.png
# Combo_Number.png
#==============================================================================

#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v1.7 - Correção de não apresentar o dano quando se usa sprites pequenos.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_combo_count] = true

module MOG_COMBO_COUNT
  #Ativar tempo para fazer combo.
  TIME_COUNT = true
  # Tempo para fazer um combo. (60 = 1s) 
  COMBO_TIME = 60
  # Cancelar a contagem de　Combo caso o inimigo acertar o herói.
  ENEMY_CANCEL_COMBO = true
  # Posição geral das imagens. X Y
  COMBO_POSITION = [20,85]
  # Posição do número de HITS. X Y
  HIT_POSITION = [25,23]
  # Posição do número de dano. X Y
  TOTAL_POSITION = [78,0]
  # Prioridade da HUD
  HUD_Z = 1
end

#===============================================================================
# ■ Game_Temp
#===============================================================================
class Game_Temp 
   attr_accessor :combo_hit
   attr_accessor :cache_combo_hit
   
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------   
   alias mog_combo_display_initialize initialize
   def initialize
       @combo_hit = [0,0,0] ; cache_cbhit
       mog_combo_display_initialize
   end

  #--------------------------------------------------------------------------
  # ● Cache Cbhit
  #--------------------------------------------------------------------------      
   def cache_cbhit
       @cache_combo_hit = []
       @cache_combo_hit.push(Cache.system("Combo_HUD"))
       @cache_combo_hit.push(Cache.system("Combo_Damage"))
       @cache_combo_hit.push(Cache.system("Combo_Number"))
   end
   
end
 
#===============================================================================
# ■ Game_Battler
#===============================================================================
class Game_Battler
  
  #--------------------------------------------------------------------------
  # ● Item Apply
  #--------------------------------------------------------------------------     
  alias mog_combo_display_item_apply item_apply
  def item_apply(user, item)
      mog_combo_display_item_apply(user, item)
      set_combo_data_d(user, item) if @result.hp_damage > 0   
  end
  
  #--------------------------------------------------------------------------
  # ● Set Combo Data D
  #--------------------------------------------------------------------------     
  def set_combo_data_d(user, item)
      if user.is_a?(Game_Actor)  
         $game_temp.combo_hit[0] += 1
         $game_temp.combo_hit[1] += @result.hp_damage 
         $game_temp.combo_hit[2] = MOG_COMBO_COUNT::COMBO_TIME
      else
         unless self.is_a?(Game_Enemy)
           $game_temp.combo_hit[2] = 0 if MOG_COMBO_COUNT::ENEMY_CANCEL_COMBO == true
         end
      end
  end
  
end

#===============================================================================
# Spriteset Battle
#===============================================================================
class Spriteset_Battle  
 
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_combo_initialize initialize
  def initialize
      create_cb_sprite
      mog_combo_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● create_cb_sprite
  #--------------------------------------------------------------------------  
  def create_cb_sprite
      @combo_sprite = Combo_Sprite_Hud.new
  end
 
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  alias mog_combo_dispose dispose
  def dispose
      mog_combo_dispose
      @combo_sprite.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● update
  #-------------------------------------------------------------------------- 
  alias mog_combo_update update
  def update
      mog_combo_update
      update_combo_hit   
  end      
  
  #--------------------------------------------------------------------------
  # ● Update Combo Hit
  #--------------------------------------------------------------------------   
  def update_combo_hit
      @combo_sprite.update
      @combo_sprite.combo_wait = (animation? or effect?) ? true : false
  end
    
end  

#===============================================================================
# ■ Combo_Sprite_Hud
#===============================================================================
class Combo_Sprite_Hud
   attr_accessor :combo_wait
   include MOG_COMBO_COUNT
   
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------
  def initialize
      $game_temp.combo_hit = [0,0,0] ; @combo_wait = false ; @combo_hit_old = 0
      @animation_speed = 0 ; @pos_x = COMBO_POSITION[0] ; @pos_x_fix = 0
      @pos_y = COMBO_POSITION[1] ; create_hud_sprite ;create_combo_sprite
      create_total_damage_sprite
   end  
   
 #--------------------------------------------------------------------------
 # ● create_hud_sprite   
 #--------------------------------------------------------------------------
 def create_hud_sprite   
     @hud = Sprite.new ; @hud.bitmap = $game_temp.cache_combo_hit[0]
     @hud.z = HUD_Z ; @hud.x = COMBO_POSITION[0] ; @hud.y = COMBO_POSITION[1]
     @hud.opacity = 250 ; @hud.visible = false
 end
   
 #--------------------------------------------------------------------------
 # ● create_total_damage_sprite
 #--------------------------------------------------------------------------
 def create_total_damage_sprite    
     @total_image = $game_temp.cache_combo_hit[1] ; @total = Sprite.new
     @total.bitmap = Bitmap.new(@total_image.width,@total_image.height)
     @total_im_cw = @total_image.width / 10 ; @total_im_ch = @total_image.height     
     @total.z = HUD_Z + 1 ; @total.visible = false
     @total_orig_x = COMBO_POSITION[0] + TOTAL_POSITION[0]
     @total_orig_y = COMBO_POSITION[1] + TOTAL_POSITION[1]
     @total.x = @total_orig_x ; @total.y = @total_orig_y
     @total.zoom_x = 1.00 ; @total.zoom_y = 1.00 ; @total.opacity = 250
  end     

#--------------------------------------------------------------------------
# ● create_combo_number  
#--------------------------------------------------------------------------
 def create_combo_sprite
     @combo_image = $game_temp.cache_combo_hit[2] ; @combo = Sprite.new
     @combo.bitmap = Bitmap.new(@combo_image.width,@combo_image.height)
     @combo_im_cw = @combo_image.width / 10 ; @combo_im_ch = @combo_image.height
     @combo.ox = @combo_im_cw / 2 ; @combo.oy = @combo_im_ch / 2
     @combo_orig_x = @combo.ox + COMBO_POSITION[0] + HIT_POSITION[0]
     @combo_orig_y = @combo.oy + COMBO_POSITION[1] + HIT_POSITION[1]
     @combo.zoom_x = 1.00 ; @combo.zoom_y = 1.00 ; @combo.opacity = 250
     @combo.z = HUD_Z + 2 ; @combo.visible = false
end  

#--------------------------------------------------------------------------
# ● Dispose
#--------------------------------------------------------------------------
   def dispose
       return if @hud == nil
       @hud.dispose ; @hud = nil ; @combo.bitmap.dispose ; @combo.dispose
       @total.bitmap.dispose ; @total.dispose
   end

#--------------------------------------------------------------------------
# ● Refresh
#--------------------------------------------------------------------------
   def refresh
     @combo_hit_old = $game_temp.combo_hit[0]
     @combo.bitmap.clear
     @combo_number_text = $game_temp.combo_hit[0].abs.to_s.split(//)
     for r in 0..@combo_number_text.size - 1
       @combo_number_abs = @combo_number_text[r].to_i 
       @combo_src_rect = Rect.new(@combo_im_cw * @combo_number_abs, 0, @combo_im_cw, @combo_im_ch)
       @combo.bitmap.blt(@combo_im_cw *  r, 0, @combo_image, @combo_src_rect)        
     end            
     @total.bitmap.clear
     @total_number_text = $game_temp.combo_hit[1].abs.to_s.split(//)
     for r in 0..@total_number_text.size - 1
       @total_number_abs = @total_number_text[r].to_i 
       @total_src_rect = Rect.new(@total_im_cw * @total_number_abs, 0, @total_im_cw, @total_im_ch)
       @total.bitmap.blt(@total_im_cw *  r, 0, @total_image, @total_src_rect)        
      end
       #Combo Position
       @pos_x_fix = (@combo_im_cw / 2 * @combo_number_text.size)
       @combo.x = @combo_orig_x - @pos_x_fix ; @combo.y = @combo_orig_y
       @combo.zoom_x = 2 ; @combo.zoom_y = 2 ; @combo.opacity = 70
       @combo.visible = true
       #Total Position      
       @total.x = @total_orig_x + 20 ; @total.y = @total_orig_y    
       @total.opacity = 100 ; @total.visible = true            
       #Hud Position 
       @hud.x = COMBO_POSITION[0] ; @hud.y = COMBO_POSITION[1] 
       @hud.opacity = 255 ; @hud.visible = true        
 end    

 #--------------------------------------------------------------------------
# ● Slide Update
#--------------------------------------------------------------------------
  def slide_update
    return if !@combo.visible
    if $game_temp.combo_hit[2] > 0 and !@combo_wait
       $game_temp.combo_hit[2] -= 1 if TIME_COUNT
    end 
    if $game_temp.combo_hit[2] > 0 and $game_temp.combo_hit[0] > 0   
         #Total Damage
         if @total.x > @total_orig_x ; @total.x -= 1 ; @total.opacity += 8
         else ; @total.x = @total_orig_x ; @total.opacity = 255
         end  
         #Combo
         if @combo.zoom_x > 1.00
            @combo.zoom_x -= 0.05 ; @combo.zoom_y -= 0.05 ; @combo.opacity += 8
         else
            @combo.zoom_x = 1 ; @combo.zoom_y = 1 ; @combo.opacity = 255
            @combo.x = @combo_orig_x - @pos_x_fix ; @combo.y = @combo_orig_y
         end           
     elsif $game_temp.combo_hit[2] == 0 and @combo.visible
           @combo.x -= 5 ; @combo.opacity -= 10 ; @total.x -= 3
           @total.opacity -= 10 ; @hud.x += 5 ; @hud.opacity -= 10     
           $game_temp.combo_hit[0] = 0 ; @combo_hit_old = $game_temp.combo_hit[0]
           $game_temp.combo_hit[1] = 0
           if @combo.opacity <= 0
           @combo.visible = false ; @total.visible = false ; @hud.visible = false
           end  
     end    
  end

#--------------------------------------------------------------------------
# ● Cancel
#--------------------------------------------------------------------------    
  def cancel
      $game_temp.combo_hit = [0,0,0] ; @combo_hit_old = 0
  end  

#--------------------------------------------------------------------------
# ● Clear
#--------------------------------------------------------------------------     
  def clear
      $game_temp.combo_hit[2] = 0
  end      

#--------------------------------------------------------------------------
# ● Update
#--------------------------------------------------------------------------
  def update
      return if @hud == nil
      refresh if $game_temp.combo_hit[0] != @combo_hit_old 
      slide_update
  end    
end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------                
  alias mog_combo_count_pre_terminate pre_terminate
  def pre_terminate
      $game_temp.combo_hit[2] = 0
      mog_combo_count_pre_terminate
  end  

end    