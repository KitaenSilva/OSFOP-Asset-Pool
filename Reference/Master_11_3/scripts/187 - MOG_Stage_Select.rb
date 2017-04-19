#==============================================================================
# +++ MOG - Stage Select (v1.0)+++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# Tela de seleção de estagio com efeitos animados.
#==============================================================================
# ● Para chamar o script use o comando abaixo.
#
# stage_select
#
#==============================================================================
# ● Para desbloquear o estagio use o código abaixo.
#
# stage_enable(ID,true)
#
# ID = ID do estagio. (Não confundir com a ID do mapa.)
# true = Coloque true/false para ativar ou desativar o estagio.
#==============================================================================
# ● GRÁFICOS
# Todas as imagens devem ser grávadas na pasta.
#
# GRAPHICS/STAGE_SELECT/
#
#==============================================================================
# ● IMAGENS DE FUNDO DOS ESTAGIOS (Todas as imagens são opcionais.)
# Nomeie as imagens da seguinte forma:
#
# Stage + ID             (Icon)
# Stage + ID + B         (Stage Background 1)
# Stage + ID + C         (Stage Background 2)
#
# Exemplo(Eg)
#
# Stage2.png
# Stage2B.png
# Stage2C.png
#==============================================================================
module MOG_STAGE_SELECT 
  # A - ID do estagio na cena de seleção de estagio.
  # B - ID do mapa que o player será teleportado.
  # C - Posição inicial X.
  # D - Posição inicial Y.
  # E - Deixar ativado o estagio ao iniciar o jogo.   
  STAGE_IDS = {
  1=>[8,8,6,true],
  2=>[10,8,6,false],
  3=>[12,8,6,false],
  4=>[13,8,6,false],
  5=>[14,8,6,false],
  6=>[2,2,7,false]
#  7=>[8,8,6,true],
#  8=>[10,8,6,false],
#  9=>[12,8,6,false],
#  10=>[13,8,6,false]
  
  }
  # Definição da velocidade de deslize da imagem de fundo.
  BACKGROUND_SCROLL_SPEED = [1,0]
  # Definição do tipo de blend da imagem de fundo 2
  BACKGROUND2_BLEND_TYPE = 1
  # Definição do tipo de blend da imagem de fundo 3
  BACKGROUND3_BLEND_TYPE = 0
  # Definição da velocidade de deslize das imagens das tiras.
  STRP1_SCROLL_SPEED = [3,0]
  STRP2_SCROLL_SPEED = [-3,0]
  # Definição do som ao ativar o teleport.
  TELEPORT_SE = "Skill3"
  # Definição da animação do jogador ao se teleportar.
  TELEPORT_ANIMATION_ID = 37
end

#==============================================================================
# ■ Game System
#==============================================================================
class Game_System
  
  attr_accessor :stage_enabled
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_stage_select_initialize initialize
  def initialize
      @stage_enabled = []
      for i in MOG_STAGE_SELECT::STAGE_IDS
          @stage_enabled[i[0]] = i[1][3]
      end  
      mog_stage_select_initialize
  end
  
end

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● Stage Enable
  #--------------------------------------------------------------------------    
  def stage_enable(st_id, active = true)
      $game_system.stage_enabled[st_id] = active
  end  
  
  #--------------------------------------------------------------------------
  # ● Stage Select
  #--------------------------------------------------------------------------  
  def stage_select
      SceneManager.call(Scene_Stage_Select)      
  end  
  
end

#==============================================================================
# ■ Cache
#==============================================================================
module Cache
  
  #--------------------------------------------------------------------------
  # ● Stage Select
  #--------------------------------------------------------------------------
  def self.stage_select(filename)
      load_bitmap("Graphics/Stage_Select/", filename)
  end
  
end

#==============================================================================
# ■ SPRITE STAGE WINDOW
#==============================================================================
class Sprite_Stage_Window < Sprite
  attr_accessor :index
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------    
  def initialize(viewport = nil , index = 0)
      super(viewport)
      @index = index
      @active = false
      if stage_enabled?
         file_name = "Stage" + (1 + @index).to_s
      else   
         file_name = "Stage0"
      end  
      self.bitmap = Cache.stage_select(file_name) rescue nil
      self.bitmap = Cache.stage_select("") if self.bitmap == nil
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
  end  
    
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------    
  def dispose
      super
      self.bitmap.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Stage Enabled ?
  #--------------------------------------------------------------------------                  
  def stage_enabled?
      return false if $game_system.stage_enabled[@index + 1] == nil  
      return false if $game_system.stage_enabled[@index + 1] == false 
      return true
  end  
  
end

#==============================================================================
# ■ Scene Stage Select * SETUP
#==============================================================================
class Scene_Stage_Select
  include MOG_STAGE_SELECT    
  
  #--------------------------------------------------------------------------
  # ● Create Bitmap
  #--------------------------------------------------------------------------            
  def create_bitmap(subject = nil, file_name = "")
      return if subject == nil
      subject.bitmap = Cache.stage_select(file_name) rescue nil
  end  
      
 #------------------------------------------------------------------------------
 # ● Main
 #------------------------------------------------------------------------------     
 def main    
     setup
     create_sprites
     execute_loop
     execute_dispose
 end
  
 #------------------------------------------------------------------------------
 # ● Execute Loop
 #------------------------------------------------------------------------------     
 def execute_loop
     Graphics.transition(30)
     loop do
          Input.update
          update
          Graphics.update          
          break if SceneManager.scene != self
     end
 end   

 #--------------------------------------------------------------------------
 # ● Setup
 #--------------------------------------------------------------------------        
 def setup
     @stages = STAGE_IDS
 end      
  
  #--------------------------------------------------------------------------
  # ● Create Sprites
  #--------------------------------------------------------------------------          
  def create_sprites
      create_background
      create_bakground_stage
      create_bakground_description
      create_stripe
      create_stage_window
  end

  #--------------------------------------------------------------------------
  # ● Create Background
  #--------------------------------------------------------------------------            
  def create_background
      @background = Plane.new
      create_bitmap(@background, "Background")
      @background.z = -5
      @b_spd = [BACKGROUND_SCROLL_SPEED[0], BACKGROUND_SCROLL_SPEED[1]]
  end  
 
  #--------------------------------------------------------------------------
  # ● Create Background Stage
  #--------------------------------------------------------------------------              
  def create_bakground_stage
      @background2 = Sprite.new
      create_bitmap(@background2, "")
      @background2.z = -4
      @background2.blend_type = BACKGROUND2_BLEND_TYPE
  end

  #--------------------------------------------------------------------------
  # ● Create Background Description
  #--------------------------------------------------------------------------                
  def create_bakground_description
      @background3 = Sprite.new
      create_bitmap(@background3, "")
      @background3.z = -3
      @background3.blend_type = BACKGROUND3_BLEND_TYPE
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh Background Stage
  #--------------------------------------------------------------------------                
  def refresh_background_stage
      if @background2.bitmap != nil
         @background2.bitmap.dispose
      end
      return unless stage_enabled?
      file_name = "Stage" + (@stage_id_active + 1).to_s + "B"
      create_bitmap(@background2, file_name)
      @background2.opacity = 0
      if @background2.bitmap != nil
         @background2.zoom_x = 1.5
         @background2.zoom_y = 1.5
         @background2.ox = @background2.bitmap.width / 2
         @background2.oy = @background2.bitmap.height / 2
         @background2.x = @background2.ox
         @background2.y = @background2.oy
      end   
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh Background Description
  #--------------------------------------------------------------------------                
  def refresh_background_description
      if @background3.bitmap != nil
         @background3.bitmap.dispose
      end
      if stage_enabled?
          file_name = "Stage" + (@stage_id_active + 1).to_s + "C"
      else
          file_name = "Stage0C"
      end    
      create_bitmap(@background3, file_name)
      @background3.opacity = 0
      @background3.x = - 120
      if @background3.bitmap != nil
         return 
         @background3.zoom_x = 1.5
         @background3.zoom_y = 1.5
         @background3.ox = @background2.bitmap.width / 2
         @background3.oy = @background2.bitmap.height / 2
         @background3.x = @background2.ox
         @background3.y = @background2.oy
      end   
  end    
  
  #--------------------------------------------------------------------------
  # ● Stage Enabled ?
  #--------------------------------------------------------------------------                  
  def stage_enabled?
      return false if $game_system.stage_enabled[@stage_id_active + 1] == nil  
      return false if $game_system.stage_enabled[@stage_id_active + 1] == false 
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Create Stripe
  #--------------------------------------------------------------------------              
  def create_stripe
      @strp1 = Plane.new
      create_bitmap(@strp1, "Strp_0")
      @strp1.z = 110 
      @strp2 = Plane.new
      create_bitmap(@strp2, "Strp_1")
      @strp2.z = 110
      @s1_spd = [STRP1_SCROLL_SPEED[0], STRP1_SCROLL_SPEED[1]]
      @s2_spd = [STRP2_SCROLL_SPEED[0], STRP2_SCROLL_SPEED[1]]
  end  
  
  #--------------------------------------------------------------------------
  # ● Create Layout
  #--------------------------------------------------------------------------
  def create_stage_window
      @sprite_pos = 0
      @slide_direction = 0
      @zoom_sprite = 0
      @zoom_sprite_phase = 0
      @zoom_speed = 0.01
      @st_center = [270,300]
      @st_left = [70,300]
      @st_right = [470,300]      
      @stage_sprites = []
      index = 0
      @stage_id_active = 0
      @stage_id_next = (@stage_id_active + 1)
      @stage_id_prev = (@stage_id_active - 1)      
      for i in @stages
          @stage_sprites.push(Sprite_Stage_Window.new(nil,index))
          index += 1
      end
      @starting = true   
      move_index(0)  
  end  
  
 #------------------------------------------------------------------------------
 # ● Check Active Window
 #------------------------------------------------------------------------------       
 def check_active_window
     @zoom_sprite = 0
     @zoom_sprite_phase = 0   
     for i in @stage_sprites
         i.visible = false
         i.opacity = 150
         i.zoom_x = 0.75
         i.zoom_y = 0.75    
         i.z = 5
         if @bitmap_range == nil
            @bitmap_range = i.width
         end   
         if @starting    
            i.x = (544 + @bitmap_range)  
            
         end   
         if i.index == @stage_id_active
            i.visible = true
            i.opacity = 255
            i.z = 10
            i.y = @st_center[1]
         elsif i.index == @stage_id_next   
            i.visible = true
            i.x = (544 + @bitmap_range) if @slide_direction == 1
            i.y = @st_right[1]
    
         elsif i.index == @stage_id_prev  
            i.visible = true
            i.x = -@bitmap_range if @slide_direction == -1
            i.y = @st_left[1]
         end    
    end
    refresh_background_stage    
    refresh_background_description
    @starting = false
 end  
  
end

#==============================================================================
# ■ Scene Stage Select * DISPOSE
#==============================================================================
class Scene_Stage_Select
  
 #------------------------------------------------------------------------------
 # ● Execute Dispose
 #------------------------------------------------------------------------------       
 def execute_dispose
     Graphics.freeze
     dispose_background
     dispose_background2
     dispose_background3
     dispose_strp
     dispose_stage_window
     Graphics.transition(30)
     $game_map.autoplay
 end
  
 #------------------------------------------------------------------------------
 # ● Dispose Background
 #------------------------------------------------------------------------------        
 def dispose_background
     return if @background == nil
     @background.bitmap.dispose if @background.bitmap != nil
     @background.dispose
 end  
  
 #------------------------------------------------------------------------------
 # ● Dispose Background 2
 #------------------------------------------------------------------------------        
 def dispose_background2
     return if @background2 == nil
     @background2.bitmap.dispose if @background2.bitmap != nil
     @background2.dispose
 end  
 
 #------------------------------------------------------------------------------
 # ● Dispose Background 3
 #------------------------------------------------------------------------------        
 def dispose_background3
     return if @background3 == nil
     @background3.bitmap.dispose if @background3.bitmap != nil
     @background3.dispose
 end   
 
 #------------------------------------------------------------------------------
 # ● Dispose Stage Window
 #------------------------------------------------------------------------------         
 def dispose_stage_window
     return if @stage_sprites == nil
     @stage_sprites.each {|sprite| sprite.dispose }
 end
 
 #------------------------------------------------------------------------------
 # ● Dispose Strp
 #------------------------------------------------------------------------------          
 def dispose_strp
     return if @strp1 == nil
     @strp1.bitmap.dispose if @strp1.bitmap != nil
     @strp1.dispose
     @strp2.bitmap.dispose if @strp2.bitmap != nil
     @strp2.dispose
 end  
end

#==============================================================================
# ■ Scene Stage Select * UPDATE
#==============================================================================
class Scene_Stage_Select
  
 #------------------------------------------------------------------------------
 # ● Update
 #------------------------------------------------------------------------------       
 def update
     update_sprites
     update_command
 end
  
 #------------------------------------------------------------------------------
 # ● Update Sprites
 #------------------------------------------------------------------------------        
 def update_sprites
     update_background_base
     update_strp
     update_stage_window
 end
 
 #------------------------------------------------------------------------------
 # ● Update Background Base
 #------------------------------------------------------------------------------         
 def update_background_base
     @background.ox += @b_spd[0]
     @background.oy += @b_spd[1]
     @background2.opacity += 15
     if @background2.zoom_x > 1.00
        @background2.zoom_x -= 0.01
        @background2.zoom_y -= 0.01
        if @background2.zoom_x <= 1.00
           @background2.zoom_x = 1.00
           @background2.zoom_y = 1.00                 
        end
     end
     if @background2.zoom_x == 1.00
        @background3.opacity += 5
        if @background3.x < 0 
           @background3.x += 5
           @background3.x = 0 if @background3.x > 0
        end
     end   
 end
 
 #------------------------------------------------------------------------------
 # ● Update strp
 #------------------------------------------------------------------------------          
 def update_strp
     @strp1.ox += @s1_spd[0]
     @strp1.oy += @s1_spd[1]   
     @strp2.ox += @s2_spd[0]
     @strp2.oy += @s2_spd[1]
 end  
 
 #------------------------------------------------------------------------------
 # ● Update Stage Window
 #------------------------------------------------------------------------------          
 def update_stage_window
     return if @stage_sprites == nil
     for i in @stage_sprites
         if i.index == @stage_id_active   
            slide_window(i.x, @st_center[0])
            i.x = @sprite_pos
            update_zoom_window(i)
            i.zoom_x = @zoom_sprite
            i.zoom_y = @zoom_sprite
         elsif i.index == @stage_id_next   
            slide_window(i.x, @st_right[0])
            i.x = @sprite_pos   
         elsif i.index == @stage_id_prev          
            slide_window(i.x, @st_left[0])
            i.x = @sprite_pos
         end               
     end  
 end
 
 #------------------------------------------------------------------------------
 # ● Update Zoom Window
 #------------------------------------------------------------------------------           
 def update_zoom_window(subject)
     @zoom_sprite = subject.zoom_x     
     if @zoom_sprite_phase == 0
        @zoom_sprite += @zoom_speed
        if @zoom_sprite >= 1.00
           @zoom_sprite = 1.00
           @zoom_sprite_phase = 1
         end   
      else 
        @zoom_sprite -= @zoom_speed
        if @zoom_sprite <= 0.75
           @zoom_sprite = 0.75
           @zoom_sprite_phase = 0
         end          
      end  
 end  
 
 #------------------------------------------------------------------------------
 # ● Slide Window
 #------------------------------------------------------------------------------           
 def slide_window(subject_position,destination)
     @sprite_pos = subject_position
     speed = [(5 + ((@sprite_pos - destination).abs / 5)).abs, 0]    
     if @sprite_pos < destination
        @sprite_pos += speed[0]
        @sprite_pos = destination if @sprite_pos > destination
     elsif @sprite_pos > destination
        @sprite_pos-= speed[0]
        @sprite_pos = destination if @sprite_pos < destination      
     end
  end            
             
end

#==============================================================================
# ■ Scene Stage Select * COMMAND
#==============================================================================
class Scene_Stage_Select
  
 #------------------------------------------------------------------------------
 # ● Update Command
 #------------------------------------------------------------------------------          
  def update_command
      if Input.trigger?(:LEFT)  
         move_index(-1) 
      elsif Input.trigger?(:RIGHT) 
         move_index(1) 
      elsif Input.trigger?(:C)
         select_stage
      elsif Input.trigger?(:B)   
         return_to_scene
      end  
  end
  
 #------------------------------------------------------------------------------
 # ● Select Stage
 #------------------------------------------------------------------------------            
 def select_stage 
     if stage_enabled?
        play_sound(TELEPORT_SE)
        $game_player.set_direction(2)
        $game_map.setup((@stages[@stage_id_active + 1][0]))
        $game_player.moveto(@stages[@stage_id_active + 1][1], @stages[@stage_id_active + 1][2])
        $game_player.clear_transfer_info        
        $game_temp.fade_type = 0
        SceneManager.goto(Scene_Map)
        $game_player.animation_id = TELEPORT_ANIMATION_ID
     else   
        Sound.play_buzzer
     end  
 end
 
 #------------------------------------------------------------------------------
 # ● Return to Scene
 #------------------------------------------------------------------------------           
 def return_to_scene
     Sound.play_cancel
     SceneManager.return
 end
 
 #------------------------------------------------------------------------------
 # ● Move Index
 #------------------------------------------------------------------------------            
  def move_index(value = 0)
      @slide_direction = value
      Sound.play_cursor    
      @subject  = 0
      @stage_id_active += value
      check_index_range(@stage_id_active)
      @stage_id_active = @subject
      check_index_range(@stage_id_active + 1)
      @stage_id_next = @subject
      check_index_range(@stage_id_active - 1)
      @stage_id_prev = @subject      
      check_active_window
  end  
  
 #------------------------------------------------------------------------------
 # ● Check Index Range
 #------------------------------------------------------------------------------              
  def check_index_range(subject)
      @subject = subject
      @subject = (@stage_sprites.size - 1) if @subject < 0
      @subject = 0 if @subject >= @stage_sprites.size    
  end
  
 #------------------------------------------------------------------------------
 # ● Play Sound
 #------------------------------------------------------------------------------                
  def play_sound(file_name,volume = 100)
      Audio.se_play("Audio/SE/" + file_name.to_s, volume, 100) rescue nil
  end   
  
end

$mog_rgss3_stage_select = true