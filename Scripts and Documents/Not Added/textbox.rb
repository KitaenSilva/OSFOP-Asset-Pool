=begin
Coder : efeberk

Script call:

show_textBox(type, length, width, variable, desc = nil)

type: :numeric, :normal, :password
length : max length of the input
width : window width
variable : which variable will own the value of the input
desc: optional

Sample : show_textbox(:numeric, 15, 200, 13, "PIN Code")

=end

module BERK
  
  CURSOR_SPEED = 20 #flashing 3 times per second ( 60 = 1 second )
  PASSWORD_CHAR = '*'
  CURSOR_CHAR = '|'
  
end

class Window_TextBox < Window_Base
  
  attr_accessor :enabled, :type
  attr_reader :finished
  
  def initialize(x, y, width, height, type, length, var)
    @text = ""
    @var = var
    @length = length
    @type = type
    @real_text = ""
    @sayac = 0;
    @cursor_show = true
    @enabled = true
    @finished = false
    super(x, y, width, height)
  end
  
  def update
    self.contents.clear
    draw_text(0, 0, contents_width, contents_height, @text, 1)
    update_cursor
    update_keyboard if @enabled
  end
  
  def update_keyboard
    if NoteInput.trigger?(NoteInput::ENTER)
      @real_text = @real_text.to_i if @type == :numeric
      $game_variables[@var] = @real_text
      @finished = true
      @text = ""
      @real_text = ""
    elsif NoteInput.trigger?(NoteInput::BACK)
      return if @real_text == ""
      @text = @text[0, @text.size - 1]
      @real_text = @real_text[0, @real_text.size - 1]
    else
      return if text_size(@text).width >= contents_width - 10 || @text.size >= @length
      case @type
      when :numeric
        k = NoteInput.key_numeric
        @text += k
        @real_text += k
      when :password
        k = NoteInput.key_type
        @text += BERK::PASSWORD_CHAR if k != ""
        @real_text += k
      when :normal
        k = NoteInput.key_type
        @text += k
        @real_text += k
      end
      
    end
    
  end
  
  def update_cursor
    @sayac += 1
    if @sayac == BERK::CURSOR_SPEED
      @cursor_show = !@cursor_show
      @sayac = 0
    end
    draw_text_ex((contents_width + text_size(@text).width) / 2 - 3, -2, BERK::CURSOR_CHAR) if @cursor_show
  end
  
end

class Scene_TextBox < Scene_Base
  
  def prepare(type, length, width, var, desc)
    @type, @length, @width, @variable, @desc = type, length, width, var, desc
  end
  
  def start
    super
    create_background
    create_textbox
  end
    
  def create_background
    @background_sprite = Spriteset_Map.new
  end
  
  def create_textbox
    if @desc
      @header = Window_Base.new((Graphics.width - @width) / 2, (Graphics.height - 24) / 2 - 48, @width, 48)
      @header.draw_text(0, 0, @header.contents_width, 24, @desc, 1)
    end
    @textbox = Window_TextBox.new((Graphics.width - @width) / 2, (Graphics.height - 24) / 2, @width, 48, @type, @length, @variable)
  end
  
  def update
    super
    NoteInput.update
    if @textbox.finished then return_scene end
  end
  
end

class Game_Interpreter
  
  def show_textBox(type, length, width, variable, desc = nil)
    SceneManager.call(Scene_TextBox)
    SceneManager.scene.prepare(type, length, width, variable, desc)
    Fiber.yield while SceneManager.scene_is?(Scene_TextBox)
  end

end