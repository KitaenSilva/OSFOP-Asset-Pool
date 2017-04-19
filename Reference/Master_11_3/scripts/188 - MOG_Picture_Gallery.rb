#==============================================================================
# +++ MOG - Picture Gallery ACE (v2.0) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# Sistema de galeria de imagens.
#==============================================================================
# Para ativar o script use o comando abaixo através de um evento usando o
# comando chamar script. (Call Script)
#
# picture_gallery
#
#==============================================================================
# Para disponibilizar as imagens na galeria você deverá usar o seguinte 
# código através do comando chamar script.
#
# enable_picture(ID)
#
# EX   enable_picture(10)
#
# Para desativar a imagem use o código abaixo
#
# disable_picture(ID)
#
#==============================================================================
# Você deverá criar uma pasta com o nome "Gallery" onde as imagens deverão
# ser gravadas.
#
# Graphics/Gallery/ 
#
# A nomeação das imagens devem ser numéricas. (ID da imagem)
# 0.jpg    (Imagem não disponível.)
# 1.jpg
# 2.jpg
# 3.jpg
# ...
#
#==============================================================================
# ● Version History
#==============================================================================
# 2.0 - Compatibilidade com resoluções maiores que o padrão normal.
#     - Compatibilidade com imagens de qualquer resolução.
#     - Velocidade de movimento baseado no tamanho da imagem.
#     - Adições de novos comandos e configurações visando melhor
#       versatilidade.
#
#==============================================================================
module MOG_PICTURE_GALLERY
       #Quantidade maxima de imagens na galeria. 
       MAX_PICTURES = 40
       #Definição da velocidade no movimento da imagem.
       SCROLL_SPEED = [3,3]
       #Definição da posição do texto de informação.
       HELP_POSITION = [0,0]
       #Definição do texto da janela de ajuda.
       HELP_TEXT = ["Page - ","Pictures"]
       #Definição da fonte da janela de ajuda.
       HELP_FONT_NAME = "Arial"             
       HELP_FONT_SIZE = 18
       HELP_FONT_BOLD = false
       #Definição da posição do cursor da página.
       # PAGE_CURSOR_POSITION = [X LEFT,Y LEFT ,X RIGHT,Y RIGHT]
       PAGE_CURSOR_POSITION = [0,0,0,0]
       #Ativar o Scene Picture Gallery no Menu
       PICTURE_GALLERY_MENU_COMMAND = true
       #Nome do comando apresentado no menu.
       PICTURE_GALLERY_COMMAND_NAME = "Picture Gallery"
end  

$imported = {} if $imported.nil?
$imported[:mog_picture_gallery] = true

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  
 attr_accessor :gallery
 
 #------------------------------------------------------------------------------
 # ● Initialize
 #------------------------------------------------------------------------------   
 alias art_picture_initialize initialize 
 def initialize
      art_picture_initialize
      @gallery = []
 end  
end

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
 #------------------------------------------------------------------------------
 # ● Picture Gallery
 #------------------------------------------------------------------------------   
 def picture_gallery
     SceneManager.call(Scene_Picture_Gallery)
 end
  
 #------------------------------------------------------------------------------
 # ● Enable Picture
 #------------------------------------------------------------------------------   
 def enable_picture(id, value = true)
     $game_system.gallery[id] = value
 end
  
 #------------------------------------------------------------------------------
 # ● Disable Picture
 #------------------------------------------------------------------------------   
 def disable_picture(id, value = false)
     $game_system.gallery[id] = value
 end 
 
end

#==============================================================================
# ■ RPG
#==============================================================================
module Cache   
  
 #------------------------------------------------------------------------------
 # ● Gallery
 #------------------------------------------------------------------------------   
 def self.gallery(filename)
     load_bitmap("Graphics/Gallery/", filename)
 end
     
end


#==============================================================================
# ■ Window_Base
#==============================================================================
class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # ● Draw_Thumbnail
  #--------------------------------------------------------------------------  
  def draw_thumbnail(x,y,id)
      bitmap = Cache.gallery(id.to_s) rescue nil
      return if bitmap == nil
      src_rect = Rect.new(0, 0, bitmap.width , bitmap.height )
      src_rect2 = Rect.new(x, y, 118, 59)  
      self.contents.stretch_blt(src_rect2, bitmap, src_rect)
      bitmap.dispose
  end
  
end  

#==============================================================================
# ■ Window_Picture
#==============================================================================
class Window_Picture < Window_Selectable
  
 #------------------------------------------------------------------------------
 # ● Initialize
 #------------------------------------------------------------------------------   
  def initialize(page)
      super(0, 64, Graphics.width, Graphics.height - 32)
      self.opacity = 0
      @index = -1
      @page = page
      @pic_max = MOG_PICTURE_GALLERY::MAX_PICTURES
      @pic_max = 1 if @pic_max <= 0
      @pag_max = @pic_max / 9
      if @pag_max == page
         o = @pag_max * 9
         o2 =  @pic_max - o
         @item_max = o2
      else
         @item_max = 9 
      end
      @i_max =  @item_max
      refresh(page)
      select(0)
      activate
  end

 #------------------------------------------------------------------------------
 # ● Refresh
 #------------------------------------------------------------------------------   
  def refresh(page = 0)
      if self.contents != nil
         self.contents.dispose
         self.contents = nil
      end
      if @item_max > 0
         self.contents = Bitmap.new(width - 32, 6 * 89)
         for i in 0...@item_max
            draw_item(i,page)
         end
      end
  end
  
 #------------------------------------------------------------------------------
 # ● WX
 #------------------------------------------------------------------------------   
  def wx
      (Graphics.width ) / 3
  end
  
 #------------------------------------------------------------------------------
 # ● WY
 #------------------------------------------------------------------------------   
  def wy
      (Graphics.height + 64) / 5 
  end
  
 #------------------------------------------------------------------------------
 # ● SX
 #------------------------------------------------------------------------------   
  def sx
      (Graphics.width / 96).truncate
  end
  
 #------------------------------------------------------------------------------
 # ● SY
 #------------------------------------------------------------------------------   
  def sy
     (Graphics.height - 416) / 12
  end  
  
 #------------------------------------------------------------------------------
 # ● draw_item
 #------------------------------------------------------------------------------   
  def draw_item(index,page)
      np = 9 * page
      picture_number = index + 1 + np
      x = sx + 16 + index % 3 * wx
      y = sy + 12 + index / 3 * wy
      s = picture_number
      s = 0 if $game_system.gallery[picture_number] == nil
      draw_thumbnail(x,y,s)
      self.contents.draw_text(x + 30,y + 49, 64, 32, "N - " + picture_number.to_s,1)
  end
  
 #------------------------------------------------------------------------------
 # ● item_rect
 #------------------------------------------------------------------------------     
  def item_rect(index)
      rect = Rect.new(0, 0, 0, 0)
      rect.width = 150
      rect.height = 90
      rect.x = sx + (@index % col_max * wx)
      rect.y = sy + (@index / col_max * wy)
      return rect
  end  
    
 #------------------------------------------------------------------------------
 # ● Col Max
 #------------------------------------------------------------------------------       
  def col_max
      return 3
  end
    
 #------------------------------------------------------------------------------
 # ● Item Max
 #------------------------------------------------------------------------------         
  def item_max
      return @item_max == nil ? 0 : @item_max 
  end  
  
end

#==============================================================================
# ■ Window Help
#==============================================================================
class Window_Help < Window_Base
  
  #--------------------------------------------------------------------------
  # * Set Text
  #--------------------------------------------------------------------------
  def set_text_pic(text)
    if text != @text
      @text = text
      refresh_pic
    end
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh_pic
    contents.clear
    draw_text_ex_pic(4, 0, @text)
  end

  #--------------------------------------------------------------------------
  # * Draw Text with Control Characters
  #--------------------------------------------------------------------------
  def draw_text_ex_pic(x, y, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    contents.font.size = MOG_PICTURE_GALLERY::HELP_FONT_SIZE
    contents.font.name = MOG_PICTURE_GALLERY::HELP_FONT_NAME
    contents.font.bold = MOG_PICTURE_GALLERY::HELP_FONT_BOLD
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end  
  
end


#==============================================================================
# ■ Scene_Picture Gallery
#==============================================================================
class Scene_Picture_Gallery
 include MOG_PICTURE_GALLERY 
  
 #------------------------------------------------------------------------------
 # ● Main
 #------------------------------------------------------------------------------     
 def main
     setup
     execute_dispose
     create_image     
     create_background     
     create_loading_text          
     create_window
     create_cursor
     create_button
     execute_loop
     execute_dispose
 end

 #------------------------------------------------------------------------------
 # ● Create_Loading
 #------------------------------------------------------------------------------      
 def create_loading_text
     @loading = Sprite.new
     @loading.bitmap = Bitmap.new(100,32)
     @loading.z = 300
     @loading.bitmap.font.size = 20
     @loading.bitmap.font.bold = true
     @loading.bitmap.font.name = "Georgia"  
     @loading.bitmap.draw_text(0,0, 100, 32, "Loading...",1)
     @loading.x = (Graphics.width / 2) - 50 
     @loading.y = (Graphics.height / 2)
     Graphics.transition(20)
 end  
 
 #------------------------------------------------------------------------------
 # ● Setup
 #------------------------------------------------------------------------------      
 def setup
     @max_pictures = MAX_PICTURES
     @max_pictures = 1 if @max_pictures <= 0
     v = (@max_pictures / 9) 
     v2 = (v - 1) * 9
     v3 = (@max_pictures - v2) - 9
     if v3 != 0
        @max_pages = (@max_pictures / 9) + 1
     else 
        @max_pages = (@max_pictures / 9) 
     end  
     @max_pages = 1 if @max_pages == 0 
     @aw_center = 0
     @aw_left = 0
     @aw_right = 0 
     @slide_type = 0
     @page_old = 0
     @picture_id = 0
     @image_active = false
     @old_index = 0
     @picures_enabled = 0
     @comp = 0
     @ex = 0
     @ey = 0
     @ex_max = 0
     @ey_max = 0
     @ex_max_zoom = 0
     @ey_max_zoom = 0
     @move_hor = true
     @move_ver = true
     @scroll_speed = [0,0]
     @pic_center_pos = [0,0]   
     for i in 0..MAX_PICTURES
         @picures_enabled += 1 if $game_system.gallery[i] 
     end  
 end  
   
 #------------------------------------------------------------------------------
 # ● create_background 
 #------------------------------------------------------------------------------        
 def create_background
     @background = Sprite.new
     @background.bitmap = Cache.gallery("Background")  
     @background.z = 0
     @background2 = Plane.new
     @background2.bitmap = Cache.gallery("Background2")      
     @background2.z = -1
 end
 
 #------------------------------------------------------------------------------
 # ● Create Window
 #------------------------------------------------------------------------------      
 def create_window
     @info = Window_Help.new
     @info.x = HELP_POSITION[0]
     @info.y = (Graphics.height - 48) + HELP_POSITION[1]
     @info.opacity = 0
     @wp_page = 0
     @wp_page_old = @wp_page
     @wp_index = 0
     @wp =[]
     for i in 0...@max_pages
         @wp[i] = Window_Picture.new(i)
     end  
     check_active_window(true)
     refresh_info_window(true)
 end
 
 #------------------------------------------------------------------------------
 # ● Create_image
 #------------------------------------------------------------------------------        
 def create_image
     @picture = Sprite.new
     @picture.bitmap = Cache.gallery("")
     @picture.z = 100
     @picture.opacity = 0
 end
 
 #------------------------------------------------------------------------------
 # ● Check Active Window
 #------------------------------------------------------------------------------       
 def check_active_window(starting = false)
     for i in 0...@max_pages
        if i == @wp_page
            @wp[@wp_page].active = true
            @wp[@wp_page].visible = true
            if @slide_type == 0   
               @wp[@wp_page].x = Graphics.width
            else
               @wp[@wp_page].x = -Graphics.width
            end   
         elsif i == @page_old  and starting == false 
            @wp[@page_old].active = false
            @wp[@page_old].visible = true
            @wp[@page_old].visible = false if starting 
            @wp[@page_old].x = 0     
         else   
            @wp[i].active = false
            @wp[i].visible = false
         end   
     end  
 end
 
 #------------------------------------------------------------------------------
 # ● Create Button
 #------------------------------------------------------------------------------       
 def create_button
     @button_image = Cache.gallery("Button")
     @button_bitmap =  Bitmap.new(@button_image.width, @button_image.height)
     @cw = @button_image.width 
     @ch = @button_image.height / 2
     src_rect = Rect.new(0, 0, @cw, @ch)
     @button_bitmap .blt(0,0, @button_image, src_rect)           
     @button = Sprite.new
     @button.bitmap = @button_bitmap
     @button.x = 2
     @button.y = Graphics.height - @ch
     @button.z = 250
     @button.opacity = 0
     @button_fade_time = 0
 end
 
 #------------------------------------------------------------------------------
 # ● Create Cursor
 #------------------------------------------------------------------------------      
 def create_cursor
     @cx1 = 0
     @cx2 = 0     
     @cursor_speed = 0
     image = Cache.gallery("Cursor")
     @bitmap = Bitmap.new(image.width, image.height)
     cw = image.width / 2
     ch = image.height
     src_rect = Rect.new(cw, 0, cw, ch)
     @bitmap.blt(0,0, image, src_rect)   
     @cx3 = Graphics.width - cw
     @cx_pos = [PAGE_CURSOR_POSITION[0],
                PAGE_CURSOR_POSITION[1] - (ch / 2),
                PAGE_CURSOR_POSITION[2] + Graphics.width - cw,
                PAGE_CURSOR_POSITION[3] - (ch / 2)
                ]
     @cursor1 = Sprite.new
     @cursor1.bitmap = @bitmap 
     @cursor1.x = @cx_pos[0] + @cx1
     @cursor1.y = @cx_pos[1] + Graphics.height / 2
     @cursor1.z = 200
     @bitmap2 = Bitmap.new(image.width, image.height)
     src_rect2 = Rect.new(0, 0, cw, ch)
     @bitmap2.blt(0,0, image, src_rect2)          
     @cursor2 = Sprite.new
     @cursor2.bitmap = @bitmap2 
     @cursor2.x = @cx_pos[2] + @cx2 
     @cursor2.y = @cx_pos[3] + Graphics.height / 2
     @cursor2.z = 200
     image.dispose
     if @max_pages == 1
        @cursor1.visible = false
        @cursor2.visible = false
     end   
 end

 #------------------------------------------------------------------------------
 # ● Execute Loop
 #------------------------------------------------------------------------------     
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
 
 #------------------------------------------------------------------------------
 # ● Execute Dispose
 #------------------------------------------------------------------------------      
 def execute_dispose
     return if @background == nil
     Graphics.freeze
     for i in 0...@max_pages
         @wp[i].dispose
     end    
     @info.dispose
     if @picture.bitmap != nil
        @picture.bitmap.dispose
     end
     @picture.dispose
     @background.bitmap.dispose
     @background.dispose
     @background = nil
     @background2.bitmap.dispose
     @background2.dispose     
     @bitmap.dispose
     @bitmap2.dispose
     @cursor1.bitmap.dispose
     @cursor1.dispose     
     @cursor2.bitmap.dispose
     @cursor2.dispose
     @button_bitmap.dispose
     @button.bitmap.dispose
     @button.dispose
     @button_image.dispose
     if @loading != nil
        @loading.bitmap.dispose
        @loading.dispose
     end   
 end
 
 #------------------------------------------------------------------------------
 # ● Update
 #------------------------------------------------------------------------------      
 def update
     @wp.each {|wid| wid.update}
     @info.update
     if @image_active  
        update_command_image
     else   
        update_command
     end   
     update_slide
     update_image_effect
     update_cursor_animation
     refresh_info_window
 end  
  
 #------------------------------------------------------------------------------
 # ● update_cursor_animation
 #------------------------------------------------------------------------------        
 def update_cursor_animation
     @cursor_speed += 1
     case @cursor_speed
        when 1..20
           @cx1 += 1
           @cx2 -= 1
        when 21..40
           @cx1 -= 1
           @cx2 += 1         
        else
        @cursor_speed = 0
        @cx1 = 0 
        @cx2 = 0
     end
     @cursor1.x = @cx_pos[0] + @cx1 
     @cursor2.x = @cx_pos[2] + @cx2
 end
   
 #------------------------------------------------------------------------------
 # ● Update Image Effect
 #------------------------------------------------------------------------------       
 def update_image_effect
     return if @wp[@wp_page].x != 0
     @button_fade_time -= 1 if @button_fade_time > 0
     if @image_active 
        @picture.opacity += 15
        if @button_fade_time != 0
           @button.opacity += 5
        else   
           if @button.y < Graphics.height  
              @button.opacity -= 10
              @button.y += 1
           end   
        end  
        @wp[@wp_page].contents_opacity -= 15
        @info.contents_opacity -= 15
        @background.opacity -= 15
        @cursor1.opacity -= 15
        @cursor2.opacity -= 15
     else  
        @picture.opacity -= 10
        @button.opacity -= 15
        @wp[@wp_page].contents_opacity += 15
        @info.contents_opacity += 15
        @background.opacity += 15
        @cursor1.opacity += 15
        @cursor2.opacity += 15        
     end  
 end

 #------------------------------------------------------------------------------
 # ● Refresh Info Window
 #------------------------------------------------------------------------------       
 def refresh_info_window(starting = false)
     return if @image_active 
     return if @wp_page_old == @wp_page and starting == false   
     @wp_page_old = @wp_page
     page = @wp_page + 1
     @picture_id = (9 * @wp_page) + @wp[@wp_page].index  + 1
     p_pages =  "         " + HELP_TEXT[0] + page.to_s + " / " + @max_pages.to_s
     comp  = "   " + "(" +(@picures_enabled.to_f / @max_pictures.to_f * 100).truncate.to_s + "%)"
     p_number = "        " + HELP_TEXT[1] + " " + @picures_enabled.to_s + " / " + @max_pictures.to_s
     @info.set_text_pic(p_pages + p_number + comp)
 end    

 #------------------------------------------------------------------------------
 # ● Update Slide
 #------------------------------------------------------------------------------       
 def update_slide
     @background2.ox += 1
     if @loading != nil
        @loading.opacity -= 5
        if @loading.opacity <= 0
           @loading.bitmap.dispose
           @loading.dispose
           @loading = nil
         end  
     end   
     return if @wp[@wp_page].x == 0  
     slide_speed = 25
     @picture.opacity = 0
     @background.opacity = 255
     if @slide_type == 1     
        if @wp[@wp_page].x < 0
           @wp[@wp_page].x += slide_speed
           if @wp[@wp_page].x >= 0
              @wp[@wp_page].x = 0 
           end
         end
        if @wp[@page_old].x < Graphics.width
           @wp[@page_old].x += slide_speed
           if @wp[@page_old].x >= Graphics.width
              @wp[@page_old].x = Graphics.width
           end
         end         
       else     
         if @wp[@wp_page].x > 0
            @wp[@wp_page].x -= slide_speed
            if @wp[@wp_page].x <= 0  
               @wp[@wp_page].x = 0
            end   
         end
         if @wp[@page_old].x > -Graphics.width
            @wp[@page_old].x -= slide_speed
            if @wp[@page_old].x <= -Graphics.width
               @wp[@page_old].x = -Graphics.width
            end
         end           
       end 
       if @slide_type == 0    
          @wp[@wp_page].x = 0 if @wp[@wp_page].x <= 0  
       else 
           @wp[@wp_page].x = 0 if @wp[@wp_page].x >= 0
       end  
 end
 
 #------------------------------------------------------------------------------
 # ● Check_limite
 #------------------------------------------------------------------------------        
 def check_limit
     if @wp_page < 0
        @wp_page = @max_pages - 1
     elsif @wp_page >= @max_pages   
        @wp_page = 0   
     end
     check_active_window
 end  
 
 #------------------------------------------------------------------------------
 # ● Update Command Image
 #------------------------------------------------------------------------------        
 def update_command_image
     if Input.trigger?(Input::B) or Input.trigger?(Input::C)
        Sound.play_cursor
        @image_active = false
        @wp[@wp_page].active = true
        return
     end   
     if Input.trigger?(Input::R) or Input.trigger?(Input::L)
        Sound.play_cursor
        execute_zoom      
     end  
     update_move_image_hor
     update_move_image_ver     
 end  
 
 #------------------------------------------------------------------------------
 # ● Update Move Image Hor
 #------------------------------------------------------------------------------        
 def update_move_image_hor
     if !@move_hor
        @picture.x = @pic_center_pos[0]
     else
        @ex += @scroll_speed[0] if Input.press?(Input::RIGHT) 
        @ex -= @scroll_speed[0] if Input.press?(Input::LEFT)
        @ex = @ex_max + @ex_max_zoom if @ex > @ex_max + @ex_max_zoom
        @ex = 0 if @ex < 0
        @picture.x = -@ex
     end
 end

 #------------------------------------------------------------------------------
 # ● Update Move Image Ver
 #------------------------------------------------------------------------------        
 def update_move_image_ver
     if !@move_ver
        @picture.y = @pic_center_pos[1]
     else
        @ey += @scroll_speed[1] if Input.press?(Input::DOWN)
        @ey -= @scroll_speed[1] if Input.press?(Input::UP)  
        @ey = @ey_max + @ey_max_zoom if @ey > @ey_max + @ey_max_zoom
        @ey = 0 if @ey < 0     
        @picture.y = -@ey
     end
 end
 
 #------------------------------------------------------------------------------
 # ● Execute Zoom
 #------------------------------------------------------------------------------         
 def execute_zoom
     if @picture.zoom_x == 1.0
        execute_zoom_in
      else 
        cancel_zoom
     end     
 end   
 
 #------------------------------------------------------------------------------
 # ● Cancel Zoom
 #------------------------------------------------------------------------------         
 def cancel_zoom         
     @ex -= @ex_max_zoom / 2 
     @ey -= @ey_max_zoom / 2           
     @picture.zoom_x = 1.0
     @picture.zoom_y = 1.0    
     @ex_max_zoom = 0
     @ey_max_zoom = 0   
     @move_hor = @picture.bitmap.width > Graphics.width ? true : false
     @move_ver = @picture.bitmap.height > Graphics.height ? true : false
     @pic_center_pos = [Graphics.width / 2 - (@picture.bitmap.width / 2),
                        Graphics.height / 2 - (@picture.bitmap.height / 2)]
     refresh_button
 end
 
 #------------------------------------------------------------------------------
 # ● Execute Zoom In 
 #------------------------------------------------------------------------------         
 def execute_zoom_in
     @picture.zoom_x = 1.5
     @picture.zoom_y = 1.5
     zoom_width = (@picture.bitmap.width + (@picture.bitmap.width / 2)) - Graphics.width
     if zoom_width.abs < Graphics.width
        @ex_max_zoom = zoom_width > 0 ? zoom_width : 0
        @move_hor = @ex_max_zoom > 0 ? true : false
        @picture.x = Graphics.width / 2 - (@picture.bitmap.width + (@picture.bitmap.width / 2)) if !@move_hor
     else
        @ex_max_zoom = (@picture.bitmap.width / 2)
        @move_hor = true 
     end
        if @ex != @ex_max 
           @ex += @ex_max_zoom / 2          
        else   
           if @ex_max != 0   
              @ex += @ex_max_zoom
           else   
              @ex += @ex_max_zoom / 2
           end  
     end  
     zoom_height = (@picture.bitmap.height + (@picture.bitmap.height / 2)) - Graphics.height
     if zoom_height.abs < Graphics.height
        @ey_max_zoom = zoom_height > 0 ? zoom_height : 0
        @move_ver = @ey_max_zoom > 0 ? true : false
     else
        @ey_max_zoom = (@picture.bitmap.height / 2) 
        @move_ver = true
     end       
     if @ey != @ey_max 
        @ey += @ey_max_zoom / 2          
     else   
        if @ey_max != 0   
           @ey += @ey_max_zoom
        else   
           @ey += @ey_max_zoom / 2
        end  
    end     
    @pic_center_pos = [Graphics.width / 2 - (@picture.bitmap.width) + (@picture.bitmap.width / 4) ,
                      Graphics.height / 2 - (@picture.bitmap.height) + (@picture.bitmap.height / 4)]    
    refresh_button
 end
 
 #------------------------------------------------------------------------------
 # ● check_avaliable_picture?
 #------------------------------------------------------------------------------        
 def check_avaliable_picture?
     @picture_id = (9 * @wp_page) + @wp[@wp_page].index  + 1 
     return false if $game_system.gallery[@picture_id] == nil
     return true
 end  
 
 #------------------------------------------------------------------------------
 # ● create_bitmap
 #------------------------------------------------------------------------------        
 def create_bitmap
     @picture.opacity = 0
     @picture.bitmap.dispose
     @picture.bitmap = Cache.gallery(@picture_id.to_s) rescue nil
     @ex = 0
     @ey = 0
     @ex_max_zoom = 0
     @ey_max_zoom = 0
     @picture.zoom_x = 1.0
     @picture.zoom_y = 1.0   
     if @picture.bitmap == nil
        @picture.bitmap = Cache.gallery("")    
        return 
     end  
     if @picture.bitmap.width > Graphics.width 
        @ex_max = @picture.bitmap.width - Graphics.width
        @move_hor = true
     else
        @ex_max = 0 
        @move_hor = false
     end
     if @picture.bitmap.height > Graphics.height
        @ey_max = @picture.bitmap.height - Graphics.height
        @move_ver = true 
     else
        @ey_max = 0
        @move_ver = false
     end   
    refresh_button
    @pic_center_pos = [Graphics.width / 2 - (@picture.bitmap.width / 2),
                       Graphics.height / 2 - (@picture.bitmap.height / 2)]
    im_size_x = @picture.bitmap.width
    im_size_y = @picture.bitmap.height
    @scroll_speed[0] = (im_size_x / 240) + SCROLL_SPEED[0]
    @scroll_speed[1] = (im_size_y / 240) + SCROLL_SPEED[1]
    @scroll_speed[0] = 1 if @scroll_speed[0] < 0
    @scroll_speed[1] = 1 if @scroll_speed[1] < 0
 end 
 
 
 #------------------------------------------------------------------------------
 # ● Refresh Button 
 #------------------------------------------------------------------------------        
 def refresh_button(type = 0)
     @button.bitmap.clear
     if @move_hor or @move_ver
        src_rect = Rect.new(0, @ch, @cw, @ch) 
     else        
        src_rect = Rect.new(0, 0, @cw, @ch)
     end  
     @button_bitmap .blt(0,0, @button_image, src_rect)  
     @button.y = Graphics.height - (@ch + 2)
     @button_fade_time = 120 
     @button.opacity = 0 unless @button.y == Graphics.height - (@ch + 2)
 end   
 
 #------------------------------------------------------------------------------
 # ● Update Command
 #------------------------------------------------------------------------------       
 def update_command
     return if @wp[@wp_page].x != 0
     if Input.trigger?(Input::B)
        Sound.play_cancel
        SceneManager.return
        return
     end
     if Input.trigger?(Input::C) 
        if check_avaliable_picture?
           Sound.play_ok
           @image_active = true
           @wp[@wp_page].active = false
           create_bitmap
        else 
          Sound.play_buzzer
        end
        return 
     end  
     if Input.trigger?(Input::L) and @max_pages != 1 
        Sound.play_cursor
        @page_old = @wp_page
        @wp_page -= 1
        @slide_type = 1
        check_limit
        return 
     elsif Input.trigger?(Input::R) and @max_pages != 1   
        Sound.play_cursor
        @page_old = @wp_page
        @wp_page += 1
        @slide_type = 0
        check_limit
        return
     end  
  end  
   
end  

if MOG_PICTURE_GALLERY::PICTURE_GALLERY_MENU_COMMAND
#==============================================================================
# ■ Window Menu Command
#==============================================================================
class Window_MenuCommand < Window_Command  
  
 #------------------------------------------------------------------------------
 # ● Add Main Commands
 #------------------------------------------------------------------------------     
  alias mog_picture_gallery_add_main_commands add_main_commands
  def add_main_commands
      mog_picture_gallery_add_main_commands
      add_command(MOG_PICTURE_GALLERY::PICTURE_GALLERY_COMMAND_NAME, :picture, main_commands_enabled)
  end
end   

#==============================================================================
# ■ Scene Menu
#==============================================================================
class Scene_Menu < Scene_MenuBase
  
 #------------------------------------------------------------------------------
 # ● Create Command Windows
 #------------------------------------------------------------------------------       
   alias mog_picture_gallery_create_command_window create_command_window
   def create_command_window
       mog_picture_gallery_create_command_window
       @command_window.set_handler(:picture,     method(:Picture_Gallery))
   end
   
 #------------------------------------------------------------------------------
 # ● Picture Gallery
 #------------------------------------------------------------------------------        
   def Picture_Gallery
       SceneManager.call(Scene_Picture_Gallery)
   end
 
end   
 
end
