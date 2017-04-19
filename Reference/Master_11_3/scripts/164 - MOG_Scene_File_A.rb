#==============================================================================
# +++ MOG - Scene File A (V1.3) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Tela de salvar e carregar animado versão A.
#==============================================================================
# Serão necessários as seguintes imagens na pasta Graphics/System 
#
# Save_Number.png
# Save_Background.png
# Save_Character_Floor.png
# Save_Layout01.png
# Save_Layout02.png 
# Save_Window01.png
# Save_Window02.png
#
#==============================================================================
#
#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v 1.3 - Melhor codificação.
# v 1.1 - Melhoria no sistema de dispose de imagens.
#==============================================================================
module MOG_SCENE_FILE
  #Quantidade de slots de saves.
  FILES_MAX = 9
end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp

  attr_accessor :scene_save
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_scene_file_initialize initialize
  def initialize
      mog_scene_file_initialize
      @scene_save = false  
  end
  
end
#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # ● draw_picture_number(x,y,value,file_name,align, space, frame_max ,frame_index)     
  #--------------------------------------------------------------------------
  # X - Posição na horizontal
  # Y - Posição na vertical
  # VALUE - Valor Numérico
  # FILE_NAME - Nome do arquivo
  # ALIGN - Centralizar 0 - Esquerda 1- Centro 2 - Direita  
  # SPACE - Espaço entre os números.
  # FRAME_MAX - Quantidade de quadros(Linhas) que a imagem vai ter. 
  # FRAME_INDEX - Definição　do quadro a ser utilizado.
  #--------------------------------------------------------------------------  
  def draw_picture_number(x,y,value, file_name,align = 0, space = 0, frame_max = 1,frame_index = 0)     
      number_image = Cache.system(file_name) 
      frame_max = 1 if frame_max < 1
      frame_index = frame_max -1 if frame_index > frame_max -1
      align = 2 if align > 2
      cw = number_image.width / 10
      ch = number_image.height / frame_max
      h = ch * frame_index
      number = value.abs.to_s.split(//)
      case align
         when 0
            plus_x = (-cw + space) * number.size 
         when 1
            plus_x = (-cw + space) * number.size 
            plus_x /= 2 
         when 2  
            plus_x = 0
      end
      for r in 0..number.size - 1       
          number_abs = number[r].to_i 
          number_rect = Rect.new(cw * number_abs, h, cw, ch)
          self.contents.blt(plus_x + x + ((cw - space) * r), y , number_image, number_rect)        
      end    
      number_image.dispose  
  end
   
  #--------------------------------------------------------------------------
  # ● Draw Help Layout
  #-------------------------------------------------------------------------- 
  def draw_face_save(name,x,y,type)
      if type == 0
         image_name = name + "_0"
      elsif type == 1
         image_name = name + "_1"         
      else  
         image_name = name + "_2"
      end
      image = Cache.face(image_name)    
      cw = image.width  
      ch = image.height 
      src_rect = Rect.new(0, 0, cw, ch)    
      self.contents.blt(x , y , image, src_rect)  
      image.dispose
  end    
    
  #--------------------------------------------------------------------------
  # ● draw_parameter_layout
  #--------------------------------------------------------------------------  
  def draw_parameter_layout(x,y)
      image = Cache.system("Save_Window01")    
      cw = image.width  
      ch = image.height 
      src_rect = Rect.new(0, 0, cw, ch)    
      self.contents.blt(x , y , image, src_rect)     
      image.dispose
  end    
  
  #--------------------------------------------------------------------------
  # ● draw_parameter_layout2
  #--------------------------------------------------------------------------  
  def draw_parameter_layout2(x,y,type)
      if type == 0
         image = Cache.system("Save_Window02")    
      else   
         image = Cache.system("Save_Window03")  
      end  
      cw = image.width  
      ch = image.height 
      src_rect = Rect.new(0, 0, cw, ch)    
      self.contents.blt(x , y , image, src_rect)     
      image.dispose
  end       
  
  #--------------------------------------------------------------------------
  # ● draw_character_floor
  #--------------------------------------------------------------------------  
  def draw_character_floor(x,y)
      image = Cache.system("Save_Character_Floor")    
      cw = image.width  
      ch = image.height 
      src_rect = Rect.new(0, 0, cw, ch)    
      self.contents.blt(x , y , image, src_rect)    
      image.dispose
  end
  
end  
    
#==============================================================================
# ■ DataManager
#==============================================================================
module DataManager

  #--------------------------------------------------------------------------
  # ● Make Save Header
  #--------------------------------------------------------------------------  
  def self.make_save_header
      header = {}
      header[:characters] = $game_party.characters_for_savefile
      header[:playtime_s] = $game_system.playtime_s
      header[:playtime] = $game_system.playtime
      header[:map_name] = $game_map.display_name
      header[:members] = $game_party.members
      header
  end  
end  

#==============================================================================
# ■ Window_SaveFile
#==============================================================================
class Window_SaveFile_A < Window_Base
  attr_reader   :filename               
  attr_reader   :file_exist               
  attr_reader   :time_stamp              
  attr_reader   :selected                 
  attr_reader   :file_index
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize(file_index, filename)
      super(0, 0,720, 140)
      self.opacity = 0
      @file_index = file_index
      @filename = filename
      load_gamedata
      refresh
      @selected = false
  end
  
  #--------------------------------------------------------------------------
  # ● load_gamedata
  #--------------------------------------------------------------------------
  def load_gamedata
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
       header = DataManager.load_header(@file_index)
       if header == nil
          @file_exist = false
          return
       end  
       @characters = header[:characters]
       @total_sec = header[:playtime]
       @mapname = header[:map_name]
       @members = header[:members]
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
      self.contents.clear
      self.contents.font.color = normal_color
      xp = 96
      ex = 60    
      if @file_exist
         if @total_sec == nil
            draw_parameter_layout2(0,50,0)
            draw_parameter_layout(-10 + xp,0)
            value = @file_index + 1
            draw_picture_number(13 + xp, 32,value, "Save_Number_01",1,0,3,0)           
            self.contents.draw_text(140, 50, 450, 32, "Error! - Please, dont't use your old Save Files...", 0)
            return
        end  
        draw_parameter_layout2(0,50,0)
        draw_parameter_layout(-10 + xp,0)
        value = @file_index + 1
        draw_picture_number(13 + xp, 32,value, "Save_Number_01",1,0,3,0) 
        draw_party_characters(180 + xp, 75,ex)
        draw_playtime(495, 20, contents.width - 4, 2)
        draw_map_location( 400 + xp,64) 
        draw_level(185 + xp,85,ex)
        draw_face_save(40 + xp,0)
      else  
        draw_parameter_layout2(0,50,1)
        draw_parameter_layout(-10 + xp,0)
        value = @file_index + 1
        draw_picture_number(13 + xp, 32,value, "Save_Number_01",1,0,3,0)       
         self.contents.draw_text(260, 50, 120, 32, "No Data", 1)
      end
    end
    
  #--------------------------------------------------------------------------
  # ● draw_face
  #--------------------------------------------------------------------------
  def draw_face_save(x,y)
     draw_actor_face(@members[0], x, y)
  end
  
  #--------------------------------------------------------------------------
  # ● draw_level
  #--------------------------------------------------------------------------
  def draw_level(x,y,ex)
      self.contents.font.color = normal_color    
      for i in 0...@members.size
        break if i > 3 
        level = @members[i].level
        draw_picture_number(x + (ex  * i) , y ,level, "Save_Number_01",1,0,3,1) 
      end        
  end 
  
  #--------------------------------------------------------------------------
  # ● draw_map_location
  #--------------------------------------------------------------------------
  def draw_map_location(x,y) 
      self.contents.font.bold = true
      self.contents.font.name = "Georgia"
      self.contents.font.size = 20
      self.contents.font.italic = true
      self.contents.draw_text(x, y, 125, 32, @mapname.to_s, 0)
  end
  #--------------------------------------------------------------------------
  # ● draw_party_characters
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y,ex)
      for i in 0...@characters.size
        break if i > 3 
        name = @characters[i][0]
        index = @characters[i][1]
        draw_character_floor(- 35 + x + i * ex,y - 20)      
        draw_character(name, index, x + i * ex, y)
      end
  end
  
  #--------------------------------------------------------------------------
  # ● draw_playtime
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
      hour = @total_sec / 60 / 60
      min = @total_sec / 60 % 60
      sec = @total_sec % 60
      time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
      draw_picture_number(x + 18 * 0, y ,0, "Save_Number_01",0,0,3,0) if hour < 10 
      draw_picture_number(x + 18 * 1, y ,hour, "Save_Number_01",0,0,3,0) 
      draw_picture_number(x + 18 * 3, y ,0, "Save_Number_01",0,0,3,0) if min < 10 
      draw_picture_number(x + 18 * 4, y ,min, "Save_Number_01",0,0,3,0) 
      draw_picture_number(x + 18 * 6, y ,0, "Save_Number_01",0,0,3,0) if sec < 10 
      draw_picture_number(x + 18 * 7, y ,sec , "Save_Number_01",0,0,3,0)     
  end
 
  #--------------------------------------------------------------------------
  # ● selected
  #--------------------------------------------------------------------------
  def selected=(selected)
      @selected = selected
  end
end

#==============================================================================
# ■ Scene Save
#==============================================================================
class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
      $game_temp.scene_save = true
      super
  end  
end  
#==============================================================================
# ■ Scene Load
#==============================================================================
class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize
      $game_temp.scene_save = false
      super
  end  
end 

#==============================================================================
# ■ Scene_File
#==============================================================================
class Scene_File 
  include MOG_SCENE_FILE
  
  
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  def initialize
      @saving = $game_temp.scene_save
      @file_max = FILES_MAX
      @file_max = 1 if FILES_MAX < 1
      execute_dispose
      create_layout
      create_savefile_windows
      @index = DataManager.last_savefile_index 
      @check_prev_index = true
      @savefile_windows[@index].selected = true    
  end
  
 #--------------------------------------------------------------------------
 # ● Main
 #--------------------------------------------------------------------------          
 def main
     Graphics.transition
     execute_loop
     execute_dispose
 end   
 
 #--------------------------------------------------------------------------
 # ● Execute Loop
 #--------------------------------------------------------------------------           
 def execute_loop
     loop do
          Graphics.update
          Input.update
          update
          if SceneManager.scene != self
              break
          end
     end
 end   
  
  #--------------------------------------------------------------------------
  # ● Create_background
  #--------------------------------------------------------------------------  
  def create_layout
      @background = Plane.new  
      @background.bitmap = Cache.system("Save_Background") 
      @background.z = 0
      @layout_01 = Sprite.new  
      @layout_01.bitmap = Cache.system("Save_Layout01") 
      @layout_01.z = 1      
      @layout_01.blend_type = 1
      image = Cache.system("Save_Layout02")
      @bitmap = Bitmap.new(image.width,image.height)
      cw = image.width 
      ch = image.height / 2
      if @saving
         h = 0
      else  
         h = ch
      end  
      src_rect = Rect.new(0, h, cw, ch)
      @bitmap.blt(0,0, image, src_rect)     
      @layout_02 = Sprite.new  
      @layout_02.bitmap = @bitmap
      @layout_02.z = 3
      @layout_02.y = 370
      image.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Dispose
  #--------------------------------------------------------------------------
  def execute_dispose
      return if @background == nil
      Graphics.freeze
      @background.bitmap.dispose
      @background.dispose
      @background = nil
      @layout_01.bitmap.dispose    
      @layout_01.dispose      
      @layout_02.bitmap.dispose
      @layout_02.dispose
      @bitmap.dispose
      dispose_item_windows
  end
  
  #--------------------------------------------------------------------------
  # ● Frame Update
  #--------------------------------------------------------------------------
  def update
      update_savefile_windows
      update_savefile_selection
      check_start_index
  end
  
  #--------------------------------------------------------------------------
  # ● check_start_index
  #--------------------------------------------------------------------------
  def check_start_index
      return if @check_prev_index == false
      @check_prev_index = false
      check_active_window   
  end  
    
  #--------------------------------------------------------------------------
  # ● check_active_window   
  #--------------------------------------------------------------------------
  def check_active_window   
      @index = 0 if @index == nil
      for i in 0...@file_max  
        @pw = @index - 1
        @pw = 0 if @pw > @file_max - 1
        @pw = @file_max- 1 if @pw < 0        
        @aw = @index 
        @nw = @index + 1
        @nw = 0 if @nw > @file_max - 1
        @nw = @file_max - 1  if @nw < 0 
        case @savefile_windows[i].file_index
           when @pw,@nw
                @savefile_windows[i].visible = true
                @savefile_windows[i].contents_opacity = 80
           when @aw  
                @savefile_windows[i].visible = true
                @savefile_windows[i].contents_opacity = 255
           else
                @savefile_windows[i].visible = false
        end 
      end          
  end
    
  #--------------------------------------------------------------------------
  # ● Create Save File Window
  #--------------------------------------------------------------------------
  def create_savefile_windows
    @pw_pos = [-160,32]
    @aw_pos = [-96,160]
    @nw_pos = [-32,288]      
    @savefile_windows = []
    for i in 0...@file_max
        @savefile_windows[i] = Window_SaveFile_A.new(i, DataManager.make_filename(i))
        @savefile_windows[i].z = 2
        @savefile_windows[i].visible = false
        @savefile_windows[i].x = 400
    end
    check_active_window
    @item_max = @file_max
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose of Save File Window
  #--------------------------------------------------------------------------
  def dispose_item_windows
      for window in @savefile_windows
          window.dispose
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Update Save File Window
  #--------------------------------------------------------------------------
  def update_savefile_windows
      update_slide_window
      for window in @savefile_windows
        window.update
      end
  end
  
  #--------------------------------------------------------------------------
  # ● update_slide_window
  #--------------------------------------------------------------------------  
  def update_slide_window
      @background.ox += 1
      slide_window_x(@pw,@pw_pos[0])
      slide_window_x(@aw,@aw_pos[0])
      slide_window_x(@nw,@nw_pos[0])
      slide_window_y(@pw,@pw_pos[1])
      slide_window_y(@aw,@aw_pos[1])
      slide_window_y(@nw,@nw_pos[1])
  end 
    
  #--------------------------------------------------------------------------
  # ● slide_window_x
  #--------------------------------------------------------------------------    
  def slide_window_x(i,x_pos)
      if @savefile_windows[i].x < x_pos
         @savefile_windows[i].x += 15
         @savefile_windows[i].x = x_pos if @savefile_windows[i].x > x_pos
      end  
      if @savefile_windows[i].x > x_pos
         @savefile_windows[i].x -= 15
         @savefile_windows[i].x = x_pos if @savefile_windows[i].x < x_pos        
       end             
  end   
     
  #--------------------------------------------------------------------------
  # ● slide_window_y
  #--------------------------------------------------------------------------    
  def slide_window_y(i,y_pos)
      if @savefile_windows[i].y < y_pos
         @savefile_windows[i].y += 15
         @savefile_windows[i].y = y_pos if @savefile_windows[i].y > y_pos
      end  
      if @savefile_windows[i].y > y_pos
         @savefile_windows[i].y -= 15
         @savefile_windows[i].y = y_pos if @savefile_windows[i].y < y_pos        
       end             
  end   
     
  #--------------------------------------------------------------------------
  # ● reset_position
  #--------------------------------------------------------------------------     
  def reset_position(diretion)
      check_active_window      
      case diretion
         when 0
            @savefile_windows[@pw].y = -64
            @savefile_windows[@pw].x = 0
         when 1  
            @savefile_windows[@nw].y = 440
            @savefile_windows[@nw].x = 0
      end        
  end 
    
  #--------------------------------------------------------------------------
  # ● Update Save File Selection
  #--------------------------------------------------------------------------
  def update_savefile_selection
      if Input.trigger?(Input::C)
         on_savefile_ok
      elsif Input.trigger?(Input::B)
         Sound.play_cancel
         return_scene
      else
        last_index = @index
        if Input.trigger?(Input::DOWN)
           execute_index(1)
           if @file_max > 2
              reset_position(1)
           else
              reset_position(0)
           end  
        end
        if Input.trigger?(Input::UP)
           execute_index(-1)
           reset_position(0)
        end
        if @index != last_index
           Sound.play_cursor
           @savefile_windows[last_index].selected = false
           @savefile_windows[@index].selected = true 
        end      
      end
  end

  #--------------------------------------------------------------------------
  # ● Execute Index
  #--------------------------------------------------------------------------  
  def execute_index(value)
      @index += value
      @index = @index >= @file_max ? 0 : @index < 0 ? (@file_max - 1) : @index
  end
  
end

$mog_rgss3_scene_file = true