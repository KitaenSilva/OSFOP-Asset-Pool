module NoteInput
  
  
  # What font will notes be written in?
  NOTE_FONT = ["Verdana"]
  
  # What size will the note's font be?
  NOTE_SIZE = 20
  
  # What color will the note font be?
  NOTE_COLOR = Color.new(255, 255, 255)
  
  # This is how much space is between each line height-wise.
  # I recommend making it 4 bigger than the NOTE_SIZE.
  NOTE_WLH = 24
  
end

#===============================================================================
# DON'T EDIT FURTHER UNLESS YOU KNOW WHAT TO DO.
#===============================================================================
class String
  
  def each_word
    array = self.split(" ")
    if block_given?
      array.each {|a| yield a }
    else
      return array
    end
  end
  
  def lines
    line_array = []
    each_line {|line|
      line_array.push(line.gsub(/[\r\n]/i, ""))
    }
    return line_array
  end
  
  def each_letter; return self.split(//i); end
end

class Game_System
  
  attr_accessor :note_input_texts
  
  alias jet1139_initialize initialize unless $@
  def initialize(*args, &block)
    jet1139_initialize(*args, &block)
    @note_input_texts = [""]
  end
end

module NoteInput
  
  include Input

  LETTERS = {}        
  LETTERS['A'] = 65; LETTERS['B'] = 66; LETTERS['C'] = 67; LETTERS['D'] = 68
  LETTERS['E'] = 69; LETTERS['F'] = 70; LETTERS['G'] = 71; LETTERS['H'] = 72
  LETTERS['I'] = 73; LETTERS['J'] = 74; LETTERS['K'] = 75; LETTERS['L'] = 76
  LETTERS['M'] = 77; LETTERS['N'] = 78; LETTERS['O'] = 79; LETTERS['P'] = 80
  LETTERS['Q'] = 81; LETTERS['R'] = 82; LETTERS['S'] = 83; LETTERS['T'] = 84
  LETTERS['U'] = 85; LETTERS['V'] = 86; LETTERS['W'] = 87; LETTERS['X'] = 88
  LETTERS['Y'] = 89; LETTERS['Z'] = 90
  NUMBERS = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57]
  NUMPAD = [96, 97, 98, 99, 100, 101, 102, 103, 104, 105] 
  BACK   = 138;
  TAB    = 139;
  ENTER  = 143; 
  SPACE  = 32;  SCOLON = 186; ESC    = 157
  QUOTE  = 222; EQUALS = 187; COMMA  = 188; USCORE = 189; PERIOD = 190
  SLASH  = 191; LBRACE = 219; RBRACE = 221; BSLASH = 220; TILDE  = 192
  F10    = 121; F11    = 122; CAPS   = 20;  NMUL   = 106; NPLUS  = 107
  NSEP   = 108; NMINUS = 109; NDECI  = 110; NDIV   = 111; Extras = 
  [USCORE, EQUALS, LBRACE, RBRACE, BSLASH, SCOLON, QUOTE, COMMA, PERIOD, SLASH,
   NMUL, NPLUS, NSEP, NMINUS, NDECI, NDIV]

  GetKeyState = Win32API.new("user32", "GetAsyncKeyState", "i", "i") 
  GetCapState = Win32API.new("user32", "GetKeyState", "i", "i") 
  KeyRepeatCounter = {}
  module_function 

  def update
    for key in KeyRepeatCounter.keys
      if (GetKeyState.call(key).abs & 0x8000 == 0x8000)
        KeyRepeatCounter[key] += 1
      else
        KeyRepeatCounter.delete(key)
      end
    end
  end
  
  def press?(key)
    adjusted_key = adjust_key(key)
    return true unless KeyRepeatCounter[adjusted_key].nil?
    return key_pressed?(adjusted_key)
  end
  
  def trigger?(key)
    adjusted_key = adjust_key(key)
    count = KeyRepeatCounter[adjusted_key]
    return ((count == 0) or (count.nil? ? key_pressed?(adjusted_key) : false))
  end
  
  def repeat?(key)
    adjusted_key = adjust_key(key)
    count = KeyRepeatCounter[adjusted_key]
    return true if count == 0
    if count.nil?
      return key_pressed?(adjusted_key)
    else
      return (count >= 23 and (count - 23) % 6 == 0)
    end
  end
  
  def adjust_key(key)
    key -= 130 if key.between?(130, 158)
    return key
  end

  def key_pressed?(key)
    if (GetKeyState.call(key).abs & 0x8000 == 0x8000)
      KeyRepeatCounter[key] = 0
      return true
    end
    return false
  end
  
  def typing?
    return true if repeat?(SPACE)
    for i in 'A'..'Z'
      return true if repeat?(LETTERS[i])
    end
    for i in 0...NUMBERS.size
      return true if repeat?(NUMBERS[i])
      return true if repeat?(NUMPAD[i])
    end
    for key in Extras
      return true if repeat?(key)
    end
    return false
  end
  
  def key_numeric
    for i in 0...NUMBERS.size
      return i.to_s if repeat?(NUMBERS[i])
      return i.to_s if repeat?(NUMPAD[i])
    end
    return ""
  end
  
  def key_type
    return " " if repeat?(SPACE)
    for i in 'A'..'Z'
      next unless repeat?(LETTERS[i])
      return upcase? ? i.upcase : i.downcase
    end
    for i in 0...NUMBERS.size
      return i.to_s if repeat?(NUMPAD[i])
      if !Input.press?(SHIFT)
        return i.to_s if repeat?(NUMBERS[i])
      elsif repeat?(NUMBERS[i])
        case i
        when 1; return "!"
        when 2; return "@"
        when 3; return "#"
        when 4; return "$"
        when 5; return "%"
        when 6; return "^"
        when 7; return "&"
        when 8; return "*"
        when 9; return "("
        when 0; return ")"
        end
      end
    end
    for key in Extras
      next unless repeat?(key)
      case key
      when USCORE; return Input.press?(SHIFT) ? "_" : "-"
      when EQUALS; return Input.press?(SHIFT) ? "+" : "="
      when LBRACE; return Input.press?(SHIFT) ? "" : ""
      when RBRACE; return Input.press?(SHIFT) ? "" : ""
      when BSLASH; return Input.press?(SHIFT) ? "" : ""
      when SCOLON; return Input.press?(SHIFT) ? "" : ""
      when QUOTE;  return Input.press?(SHIFT) ? "" : ""
      when COMMA;  return Input.press?(SHIFT) ? "<" : ","
      when PERIOD; return Input.press?(SHIFT) ? ">" : "."
      when SLASH;  return Input.press?(SHIFT) ? "?" : "/"
      when NMUL;   return "*"
      when NPLUS;  return "+"
      when NSEP;   return ""
      when NMINUS; return "-"
      when NDECI;  return "."
      when NDIV;   return "/"
      end
    end
    return ""
  end
  
  def upcase?
    return !Input.press?(SHIFT) if GetCapState.call(CAPS) == 1
    return true if Input.press?(SHIFT)
    return false
  end
end