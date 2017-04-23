#==============================================================================
# +++ MOG - Battleback EX (v2.3) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Adiciona efeitos animados nos battlebacks e camadas infinitas.
#==============================================================================
# ● UTILIZAÇÃO
#==============================================================================
# Use os códigos abaixo através do comando chamar script.
# NOTA - Os códigos podem ser usados no meio da  batalha.
# 
# bb(LAYER_ID ,EFFECT ,POWER A, POWER B , BLENDY_TYPE , SCREEN_Z, FADE_SPEED )
#
# TYPE = 0...4
#
# 0 = Efeito slide
# 1 = Efeito wave
# 2 = Normal
# 3 = Battleback animado por frames.
# 4 = Perspective (Battle Camera)
#
# POWER 1  
# 
# Velocidade de deslize na horizontal no efeito SLIDE.
# Area de distorção no efeito WAVE. (de 0 a 20)
#
# POWER 2
# 
# Velocidade de deslize na vertical no efeito SLIDE.
# Velocidade de distorção do efeito WAVE.
# Velocidade de animação no efeito 2.
#
# BLENDY_TYPE  (Opcional)
# Efeito de blendy de 0 a 2
#
# SCREEN_Z (Opcional)
# Posição Z da camada. (Valores acima de 100 ficam acima dos battlers)
#
# FADE_SPEED Opcional (Opcional)
# Velocidade de Fade. (0 = Desativar)
#
#
# Exemplo.
#
# bb(1,1,20,20)
#
#==============================================================================
# ● Cancelar o Efeito.
#==============================================================================
# Para cancelar o efeito use o código abaixo.
#
# bb_clear
#
#==============================================================================
# Efeito de animação por frames. (Efeito tipo 3)
#==============================================================================
# Para ativar o efeito de animação por frames é necessário ter e nomear os
# arquivos da seguinte forma.
#
# Picture_Name.png  (A imagem que deve ser escolhida no comando do evento.)
# Picture_Name0.png
# Picture_Name1.png
# Picture_Name2.png
# Picture_Name3.png
# Picture_Name4.png
# ...
#==============================================================================
# DEFININDO MULTIPLAS CAMADAS (Acima de 2 camadas - Padrão)
#==============================================================================
# Para ativar camadas extras utilize o código abaixo.
#
# bb_name(LAYER_ID ,FILE_NAME)
#
# LAYER_ID   = ID da Camada
# FILE_NAME  = Nome do arquivo
#
# Exemplo
#
#
# bb_name(1,"BlueSky")
# bb_name(2,"Fog_03")
# bb_name(3,"Grassland_01B")
# bb_name(4,"Fog_02")
# ...
# 
#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v 2.3 - Adição do modo perspective.
# v 2.2 - Compatibilidade com MOG Battle Camera.
# v 2.1 - Melhoria no sistema de bitmap.
# v 2.0 - Função do Battleback Animado por frames.
#==============================================================================
module MOG_BATTLEBACK_EX
  # Definição da posição Z do Battleback (Apenas para ajustes de compatibilidade)
  # É possível modificar o valor no meio do jogo usando o código abaixo.
  #
  # bb_screen_z(X)
  #
  SCREEN_Z = 0
end

$imported = {} if $imported.nil?
$imported[:mog_battleback_ex] = true

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
   
  attr_accessor :bb_fade_duration
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------             
  alias mog_bb_ex_initialize_temp initialize
  def initialize
      @bb_fade_duration = [0 , true]
      mog_bb_ex_initialize_temp
  end  
  
end  
#==============================================================================
# ■ Game System
#==============================================================================
class Game_System
  
  attr_accessor :bb_data
  attr_accessor :bb_name
  attr_accessor :bb_screen_z
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------           
  alias mog_bb_ex_initialize initialize
  def initialize
      @bb_data = [] ; @bb_name = [] ; @bb_screen_z = MOG_BATTLEBACK_EX::SCREEN_Z
      mog_bb_ex_initialize
  end  
  
end

#==============================================================================
# ■ Spriteset Battle
#==============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  alias mog_bb_ex_initialize initialize
  def initialize
      $game_temp.bb_fade_duration = [0,false] ; @back_sprite_ex = []
      @bba_bitmap = [] ; @bba_frames = [] ; @bb_data = [] 
      mog_bb_ex_initialize
      create_battleback_ex
      update
  end  

  #--------------------------------------------------------------------------
  # ● Create Battkeback EX
  #--------------------------------------------------------------------------    
  def create_battleback_ex
      $game_system.bb_name.each_with_index do |bb, index|
      create_bbex_sprite(bb, index) if bb != nil and !bb.empty?
      end      
  end

  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------    
  alias mog_bb_exm_dispose dispose
  def dispose
      dispose_battleback_ex
      mog_bb_exm_dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Batleback1
  #--------------------------------------------------------------------------    
  alias mog_bb_ex_dispose_battleback1 dispose_battleback1
  def dispose_battleback1
      mog_bb_ex_dispose_battleback1
      dispose_battleback_ex ; dispose_sprites_a(0)
  end

  #--------------------------------------------------------------------------
  # ● Dispose Batleback2
  #--------------------------------------------------------------------------    
  alias mog_bb_ex_dispose_battleback2 dispose_battleback2
  def dispose_battleback2
      mog_bb_ex_dispose_battleback2
      dispose_sprites_a(1)
  end  

  #--------------------------------------------------------------------------
  # ● Dispose Battleback
  #--------------------------------------------------------------------------    
  def dispose_battleback_ex
      return if @back_sprite_ex == nil
      @back_sprite_ex.compact.each_with_index {|sprite,index|
      sprite.bitmap.dispose rescue nil ; sprite.dispose; dispose_sprites_a(index)}  
  end  

  #--------------------------------------------------------------------------
  # ● Disposes Sprites A
  #--------------------------------------------------------------------------          
  def dispose_sprites_a(type)
      @bba_bitmap[type].each {|sprite| sprite.dispose } if @bba_bitmap[type]
      @bba_bitmap[type] = nil
  end  

  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  alias mog_bb_ex_update update
  def update
      update_battleback_transition
      mog_bb_ex_update
  end

  #--------------------------------------------------------------------------
  # ● Update Battleback Transition
  #--------------------------------------------------------------------------        
  def update_battleback_transition
      @back_sprite_ex.each_with_index {|sprite,index| update_battleback_ex(index,@back1_sprite.opacity) }
      return if $game_temp.bb_fade_duration[0] == 0
      if $game_temp.bb_fade_duration[1]
         $game_temp.bb_fade_duration = [0 , false] ; refresh_bb_ex
         @back1_sprite.opacity = 255 if @back1_sprite != nil
      end  
      $game_temp.bb_fade_duration[0] -= 1
      case $game_temp.bb_fade_duration[0]
           when 129..300
              @back1_sprite.opacity -= 2 if @back1_sprite != nil
           when 1..128
              if $game_temp.bb_fade_duration[0] == 128
                 refresh_bb_ex 
                 @back1_sprite.opacity = 0 if @back1_sprite != nil
              end   
              @back1_sprite.opacity += 2 if @back1_sprite != nil
           else    
              @back1_sprite.opacity = 255 if @back1_sprite != nil
      end      
      @back2_sprite.opacity = @back1_sprite.opacity if @back2_sprite != nil
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh Battleback EX
  #--------------------------------------------------------------------------          
  def refresh_bb_ex  
      dispose_battleback1 ; dispose_battleback2 ; dispose_battleback_ex
      create_battleback1 ; create_battleback2 ; create_battleback_ex
  end    
  
  #--------------------------------------------------------------------------
  # ● Create_Battleback1
  #--------------------------------------------------------------------------
  def create_battleback1
      dispose_sprites_a(0) ; @bb_data[0] = [] if @bb_data[0] == nil
      $game_system.bb_data[0] = [] if $game_system.bb_data[0] == nil
      if !$game_system.bb_data[0].empty? ; create_bb1_ex ; return ; end
      c_normal_sprite(0)  
  end

  #--------------------------------------------------------------------------
  # ● Create_battleback2
  #--------------------------------------------------------------------------
  def create_battleback2
      dispose_sprites_a(1) ; @bb_data[1] = [] if @bb_data[1] == nil
      $game_system.bb_data[1] = [] if $game_system.bb_data[1] == nil
      if !$game_system.bb_data[1].empty? ; create_bb2_ex ; return ; end
      c_normal_sprite(1)   
  end

  #--------------------------------------------------------------------------
  # ● Dispose BB EX
  #--------------------------------------------------------------------------    
  def dispose_bb_ex(type) 
      sprite = set_current_battleback(type)
      return if sprite == nil
      sprite.bitmap.dispose rescue nil ; sprite.dispose ; sprite = nil
      dispose_sprites_a(type)
  end     
    
  #--------------------------------------------------------------------------
  # ● Set Current Battleback
  #--------------------------------------------------------------------------    
  def set_current_battleback(type)
      return @back1_sprite if type == 0
      return @back2_sprite if type == 1
      return @back_sprite_ex[type] if type >= 2    
  end
  
  #--------------------------------------------------------------------------
  # ● Set Current BB Name
  #--------------------------------------------------------------------------    
  def set_current_bb_name(type)
      return battleback1_name if type == 0
      return battleback2_name if type == 1
      return $game_system.bb_name[type] if type >= 2
  end
  
  #--------------------------------------------------------------------------
  # ● Set Current Bitmap
  #--------------------------------------------------------------------------    
  def set_current_bitmap(type)
      return battleback1_bitmap if type == 0
      return battleback2_bitmap if type == 1
      if type >= 2
         if @back_sprite_ex[type].bitmap == nil
            return Cache.battleback2($game_system.bb_name[type]) 
         else   
            return @back_sprite_ex[type].bitmap
         end  
      end
  end      
  
  #--------------------------------------------------------------------------
  # ● Create BB 1 EX
  #--------------------------------------------------------------------------  
  def create_bb1_ex
      clear_base_bb_ex(0)
      if set_current_bb_name(0) == nil ; c_normal_sprite(0) ; return ; end
      @bb_data1_oxy = [0,0]  
      case $game_system.bb_data[0][0]
          when 0
            @back1_sprite = Plane.new(@viewport1)
            @back1_sprite.bitmap = battleback1_bitmap  
            stretch_battleback(@back1_sprite) if $imported[:mog_battle_camera]
          when 1  
            @back1_sprite = Sprite.new(@viewport1) ; set_bb_wave(0)
            center_sprite_wave(@back1_sprite,0)
          when 2               
            @back1_sprite = Sprite.new(@viewport1) 
            set_animated_bb(0,@back1_sprite, battleback1_bitmap,$game_system.bb_data[0][1])            
            center_sprite(@back1_sprite)
          else ; c_normal_sprite(0)
      end
      @bb_data[0] = $game_system.bb_data[0] ; set_data_misc(0)
      @back1_sprite.z = $game_system.bb_screen_z + @bb_data[0][4]
      @back1_sprite.blend_type = @bb_data[0][3]
      if $imported[:mog_battle_camera]
         @bb_data1_oxy[0] = (@back1_sprite.bitmap.width - Graphics.width) / 2
         @bb_data1_oxy[1] = (@back1_sprite.bitmap.width - Graphics.width) / 2
      end   
  end
  
  #--------------------------------------------------------------------------
  # ● Create BB 2 EX
  #--------------------------------------------------------------------------    
  def create_bb2_ex
      clear_base_bb_ex(1)     
      if set_current_bb_name(1) == nil ; c_normal_sprite(1) ; return ; end    
      @bb_data2_oxy = [0,0]      
      case $game_system.bb_data[1][0]
          when 0
            @back2_sprite = Plane.new(@viewport1) 
            @back2_sprite.bitmap = battleback2_bitmap
            stretch_battleback(@back2_sprite) if $imported[:mog_battle_camera]
          when 1  
            @back2_sprite = Sprite.new(@viewport1) ; set_bb_wave(1)
            center_sprite_wave(@back2_sprite,1) 
          when 2   
            @back2_sprite = Sprite.new(@viewport1) 
            set_animated_bb(1,@back2_sprite,battleback2_bitmap,$game_system.bb_data[1][1])
            center_sprite(@back2_sprite)
          else ; c_normal_sprite(1)
          end     
      @bb_data[1] = $game_system.bb_data[1] ; set_data_misc(1)
      @back2_sprite.z = 1 + $game_system.bb_screen_z  + @bb_data[1][4] 
      @back2_sprite.blend_type = @bb_data[1][3]
      if $imported[:mog_battle_camera]
         @bb_data2_oxy[0] = (@back2_sprite.bitmap.width - Graphics.width) / 2
         @bb_data2_oxy[1] = (@back2_sprite.bitmap.height - Graphics.width) / 2
      end   
  end 
    
  #--------------------------------------------------------------------------
  # ● Create BB EX Sprite
  #--------------------------------------------------------------------------    
  def create_bbex_sprite(bb, index)
      @bb_data_oxy = [] if @bb_data_oxy == nil
      @bb_data[index] = [] if @bb_data[index] == nil
      @bb_data_oxy[index] = [0,0]
      $game_system.bb_data[index] = [] if $game_system.bb_data[index] == nil   
      clear_base_bb_ex(index)         
      case $game_system.bb_data[index][0]
          when 0
            @back_sprite_ex[index] = Plane.new(@viewport1) 
            @back_sprite_ex[index].bitmap = Cache.battleback2($game_system.bb_name[index])      
            stretch_battleback(@back_sprite_ex[index]) if $imported[:mog_battle_camera]
          when 1  
            @back_sprite_ex[index] = Sprite.new(@viewport1) 
            @back_sprite_ex[index].bitmap = Cache.battleback2($game_system.bb_name[index])  
            set_bb_wave(index) ; center_sprite_wave(@back_sprite_ex[index],index) 
          when 2   
            @back_sprite_ex[index] = Sprite.new(@viewport1) 
            set_animated_bb(index,@back_sprite_ex[index],set_current_battleback(index),$game_system.bb_data[index][1])
            center_sprite(@back_sprite_ex[index]) 
          else
            @back_sprite_ex[index] = Sprite.new(@viewport1) 
            set_bitmap_background(@back_sprite_ex[index],index)
       end     
      @bb_data[index] = $game_system.bb_data[index] ; set_data_misc(index)
      @back_sprite_ex[index].z = index + $game_system.bb_screen_z + @bb_data[index][4]
      @back_sprite_ex[index].blend_type = @bb_data[index][3]
      if $imported[:mog_battle_camera]
         @bb_data_oxy[index][0] = (@back_sprite_ex[index].bitmap.width - Graphics.width) / 2
         @bb_data_oxy[index][1] = (@back_sprite_ex[index].bitmap.height - Graphics.height) / 2
      end   
  end   

  #--------------------------------------------------------------------------
  # * Move Sprite to Screen Center
  #--------------------------------------------------------------------------
  def center_sprite_wave(sprite,index)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    sprite.x = Graphics.width / 2
    sprite.y = Graphics.height / 2
  end  
  
  #--------------------------------------------------------------------------
  # ● Set Data Misc
  #--------------------------------------------------------------------------    
  def set_data_misc(index)
      @bb_data[index][5] = 0 
      @bb_data[index][6] = 0     
      opm =  @bb_data[index][10] > 0 ? @bb_data[index][10] : 1
      @bb_data[index][7] = 255 / opm
      @bb_data[index][8] = 0 
      @bb_data[index][9] = 255  
  end
      
  #--------------------------------------------------------------------------
  # ● C Normal Sprite
  #--------------------------------------------------------------------------  
  def c_normal_sprite(type)
      @back1_sprite = Sprite.new(@viewport1) if type == 0
      @back2_sprite = Sprite.new(@viewport1) if type == 1
      sprite = type == 0 ? @back1_sprite : @back2_sprite
      set_bitmap_background(sprite,type)
  end      
  
  #--------------------------------------------------------------------------
  # ● Set Bitmap Background
  #--------------------------------------------------------------------------  
  def set_bitmap_background(sprite,type)
      sprite_bitmap = set_current_bitmap(type)
      bw = sprite_bitmap.width < Graphics.width ? Graphics.width : sprite_bitmap.width
      bh = sprite_bitmap.height < Graphics.height ? Graphics.height : sprite_bitmap.height
      sprite.bitmap = Bitmap.new(bw,bh)
      sprite.bitmap.stretch_blt(sprite.bitmap.rect, sprite_bitmap, sprite_bitmap.rect) 
      sprite.z = type ; center_sprite(sprite)
  end   
      
  #--------------------------------------------------------------------------
  # ● Clear Base BB EX
  #--------------------------------------------------------------------------    
  def clear_base_bb_ex(type)
      if $game_system.bb_data[type] == nil or $game_system.bb_data[type].empty?
         $game_system.bb_data[type] = [0,0,0,0,0,0,0,0,0,0,0]
      end   
      dispose_sprites_a(type)
      return if $game_system.bb_data[type] == nil or $game_system.bb_data[type].empty?
      $game_system.bb_data[type][0] = 0 if $game_system.bb_data[type][0] > 3
      $game_system.bb_data[type][1] = 0 if $game_system.bb_data[type][1] == nil
      $game_system.bb_data[type][2] = 0 if$game_system.bb_data[type][2] == nil    
  end
  
  #--------------------------------------------------------------------------
  # ● Set bb Wave
  #--------------------------------------------------------------------------    
  def set_bb_wave(type)
      bb_data = $game_system.bb_data[type]
      if $imported[:mog_battle_camera]
         range = range = (bb_data[1] + 1) * 5 ; range = 500 if range > 500
         rxy = [Graphics.width * camera_range / 100,Graphics.height * camera_range / 100]
      else
         range = (bb_data[1] + 1) * 5 ; range = 500 if range > 500
         rxy = [0,0]
      end
      speed = (bb_data[2] + 1) * 100 ; speed = 1000 if speed > 1000 
      sprite = set_current_battleback(type)
      sprite_bitmap = set_current_bitmap(type)
      sprite.x = -range
      sprite.wave_amp = range
      sprite.wave_length = Graphics.width
      sprite.wave_speed = speed        
      sprite.bitmap = Bitmap.new(Graphics.width + rxy[0] + (range * 2),Graphics.height + rxy[1])
      sprite.bitmap.stretch_blt(sprite.bitmap.rect, sprite_bitmap, sprite_bitmap.rect) 
  end  
  
  #--------------------------------------------------------------------------
  # ● Set Animated BB
  #--------------------------------------------------------------------------    
  def set_animated_bb(type,sprite,sprite_bitmap,speed)
      @bba_bitmap[type] = [] ; @bba_frames[type] = [0,0,speed]
      for index in 0..999
        if type == 0
           @bba_bitmap[type].push(Cache.battleback1(set_current_bb_name(type) + index.to_s)) rescue nil
         else
           @bba_bitmap[type].push(Cache.battleback2(set_current_bb_name(type) + index.to_s)) rescue nil
        end
        break if @bba_bitmap[type][index] == nil
      end
      if @bba_bitmap[type].size <= 1
         @bba_bitmap[type] = nil ; @bba_frames[type] = nil
         sprite.bitmap = set_current_bitmap(type) ; return
      end   
      refresh_bb_anime(type,sprite)  
  end
  
  #--------------------------------------------------------------------------
  # ● Update Background An
  #--------------------------------------------------------------------------    
  def update_background_an(type,sprite)
      return if @bba_frames[type] == nil
      @bba_frames[type][1] += 1
      refresh_bb_anime(type,sprite) if @bba_frames[type][1] >= @bba_frames[type][2]
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh BB anime
  #--------------------------------------------------------------------------    
  def refresh_bb_anime(type,sprite)
      sprite.bitmap = @bba_bitmap[type][@bba_frames[type][0]]
      @bba_frames[type][0] += 1 ; @bba_frames[type][1] = 0
      @bba_frames[type][0] = 0 if @bba_frames[type][0] >= @bba_bitmap[type].size
  end

  #--------------------------------------------------------------------------
  # ● Update BB Scroll
  #--------------------------------------------------------------------------
  def update_bb_scroll(index)
      @bb_data[index][5] += @bb_data[index][1]
      @bb_data[index][6] += @bb_data[index][2]
      @bb_data[index][5] = 0 if @bb_data[index][5] >= 99999999
      @bb_data[index][6] = 0 if @bb_data[index][6] >= 99999999
  end  
 
  #--------------------------------------------------------------------------
  # ● Update Opacity EX
  #--------------------------------------------------------------------------
  def update_bb_opacity(index,sprite)
      @bb_data[index][6] += 1
      return if @bb_data[index][6] < @bb_data[index][5]
      @bb_data[index][6] = 0 ; @bb_data[index][8] += 1
      case @bb_data[index][8]
        when 0..@bb_data[index][10]
           @bb_data[index][9] -= @bb_data[index][7]
        when @bb_data[index][10]..(-1 + @bb_data[index][10] * 2)
           @bb_data[index][9] += @bb_data[index][7]
        else
           @bb_data[index][9] = 255 ; @bb_data[index][8] = 0
      end
      sprite.opacity = @bb_data[index][9]
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Battleback1
  #--------------------------------------------------------------------------
  def update_battleback1
      if !@bb_data[0].empty?
          case @bb_data[0][0]
             when 0 
               update_bb_scroll(0)
               @back1_sprite.ox = @bb_data[0][5] + @bb_data1_oxy[0]
               @back1_sprite.oy = @bb_data[0][6] + @bb_data1_oxy[1]
             when 2 ; update_background_an(0,@back1_sprite)
             when 3 ; bb_camera_effect(@back1_sprite,0)
             else ; @back1_sprite.update
          end
          return
      end    
      @back1_sprite.update
  end

  #--------------------------------------------------------------------------
  # ● Update Battleback2
  #--------------------------------------------------------------------------
  def update_battleback2
      if !@bb_data[1].empty?
         case @bb_data[1][0]
             when 0 
                update_bb_scroll(1)
                @back2_sprite.ox = @bb_data[1][5] + @bb_data2_oxy[0]
                @back2_sprite.oy = @bb_data[1][6] + @bb_data1_oxy[1]
             when 2 ; update_background_an(1,@back2_sprite)
             when 3 ; bb_camera_effect(@back2_sprite,1)
             else ; @back2_sprite.update
         end 
         return    
      end       
      @back2_sprite.update
  end
  
  #--------------------------------------------------------------------------
  # ● Update Battleback EX
  #--------------------------------------------------------------------------
  def update_battleback_ex(index,opacity)
      return if @back_sprite_ex[index].nil? or @back_sprite_ex[index].disposed?
      if @bb_data[index][10] > 0 and $game_temp.bb_fade_duration[0] == 0
         update_bb_opacity(index,@back_sprite_ex[index])
      else
         @back_sprite_ex[index].opacity = opacity if opacity != nil
      end
      if !@bb_data[index].empty?
          case @bb_data[index][0]
             when 0 
               update_bb_scroll(index) 
               @back_sprite_ex[index].ox = @bb_data[index][5] + @bb_data_oxy[index][0]
               @back_sprite_ex[index].oy = @bb_data[index][6] + @bb_data_oxy[index][1]
             when 2 ; update_background_an(index,@back_sprite_ex[index])  
             when 3 ; bb_camera_effect(@back_sprite_ex[index],index)
             else ; @back_sprite_ex[index].update
          end
          return
      end    
      @back_sprite_ex[index].update      
  end  
  
  #--------------------------------------------------------------------------
  # ● BB Camera Effect
  #--------------------------------------------------------------------------
  def bb_camera_effect(sprite,index)
      bx = [[@bb_data[index][1], 100].min, -100].max
      by = [[@bb_data[index][2], 100].min, -100].max
      vx = @viewport1.ox * bx / 100
      vy = @viewport1.oy * by / 100
      sprite.ox = (sprite.bitmap.width / 2) -@viewport1.ox + vx
      sprite.oy = (sprite.bitmap.height / 2) -@viewport1.oy  + vy
  end
  
end

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter

  #--------------------------------------------------------------------------
  # ● BB
  #--------------------------------------------------------------------------      
  def bb(id ,type = 0 , power = 0 , power2 = 0, blend_type = 0, screen_z = 0,a_fade = 0)
      return if id <= 0
      id -= 1 if [1,2].include?(id)
      $game_system.bb_data[id] = [] if $game_system.bb_data[id] == nil
      if (type == nil or type < 0) ; $game_system.bb_data[id].clear 
      else ; $game_system.bb_data[id] = [type, power, power2,blend_type, screen_z,
                                         0,0,0,0,0,a_fade]
      end   
      $game_temp.bb_fade_duration[0] = 256 if SceneManager.scene_is?(Scene_Battle)
  end

  #--------------------------------------------------------------------------
  # ● BB Name 
  #--------------------------------------------------------------------------      
  def bb_name(id,name = "")
      if name == nil ; $game_system.bb_name[id].clear rescue nil ; return ; end    
      return if id <= 0
      if [1,2].include?(id)
         $game_map.change_battleback_name(id,name) ; return
      end
      $game_system.bb_name[id] = name
  end
  
  #--------------------------------------------------------------------------
  # ● BB Clear
  #--------------------------------------------------------------------------      
  def bb_clear
      $game_system.bb_data.clear
      $game_system.bb_name.clear
  end
  
  #--------------------------------------------------------------------------
  # ● BB Screen Z
  #--------------------------------------------------------------------------      
  def bb_screen_z(value)
      $game_system.bb_screen_z = value
  end  
  
end  

#==============================================================================
# ■ Game Map
#==============================================================================
class Game_Map
  
  #--------------------------------------------------------------------------
  # * Change Battle Background
  #--------------------------------------------------------------------------
  def change_battleback_name(type,battleback_name)
      @battleback1_name = battleback_name if type == 1
      @battleback2_name = battleback_name if type == 2
      $game_temp.bb_fade_duration = [256, false] if SceneManager.scene_is?(Scene_Battle)
  end  
  
  #--------------------------------------------------------------------------
  # ● Change_Battleback
  #--------------------------------------------------------------------------  
   alias mog_bbex_change_battleback change_battleback
   def change_battleback(battleback1_name, battleback2_name)
       mog_bbex_change_battleback(battleback1_name, battleback2_name)
       $game_temp.bb_fade_duration = [256, false] if SceneManager.scene_is?(Scene_Battle)
   end

end