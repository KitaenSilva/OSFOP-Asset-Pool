################################################################################
#    HTML-Rendering Engine 1.5.2                                               #
#         by Tidloc (orignal idea and creation by Caesar)                      #
#==============================================================================#
#  Available HTML-tags:                                                        #
#  <if=*x*>*s1*<else>*s2*</else>                                               #
#     if the game switch with the ID x is true showing s1. if it's false       #
#     showing s2.                                                              #
#  <f=*x*>s1</f>                                                               #
#     if the game switch with the ID x is true showing s1. if it's false       #
#     showing nothing.                                                         #
#  <v[*x*]>*y*>s1</v>                                                          #
#     if the game variable with ID x is bigger then the value y, s1 is shown.  #
#     if its lower, nothing is shown                                           #
#  <v[*x*]<*y*>s1</v>                                                          #
#     if the game variable with ID x is lower then the value y, s1 is shown.   #
#     if its bigger, nothing is shown                                          #
#  <var=*x*>                                                                   #
#     showing the value of the game variable with the ID x.                    #
#  {eval=*x*}                                                                  #
#     intepreting the script command written with in x.                        #
#  <style=*x*>                                                                 #
#     changing the text style to x if x is listed in the STYLES.               #
#  <br>                                                                        #
#     linefeed, like the command \n.                                           #
#  <b>                                                                         #
#     writing text bold until </b>                                             #
#  <i>                                                                         #
#     writing text italic until </i>                                           #
#  <u>                                                                         #
#     writing text underlined until </u>                                       #
#  <color=*x*>                                                                 #
#     changes the textcolor to x, where x may be:                              #
#     #7f7f7f ........ any hexcode with a # before                             #
#     system_color ... any scriptcalls of colors                               #
#  <shadow>                                                                    #
#     showing text shadowed until </shadow>                                    #
#  <small>                                                                     #
#     decreasing fontsize until </small>                                       #
#  <big>                                                                       #
#     increasing fontsize until </big>                                         #
#  <size=*x*>                                                                  #
#     setting fontsize to x until </size>                                      #
#  <font=*x*>                                                                  #
#     changing to font x until </font>                                         #
#  <icon=*x*>                                                                  #
#     showing the Icon with the ID x.                                          #
#  <img=*x*>                                                                   #
#     showing the image with the name x in your folder \Graphics\pictures.     #
#  <down=*x*>                                                                  #
#     linefeed with additional x pixellines left empty.                        #
#  <space=*x*>                                                                 #
#     feeding x pixels to the right without writing anythin in it.             #
#  <line>                                                                      #
#     linefeed with drawing a line inbetween.                                  #
#  <actor=*x*>                                                                 #
#     showing the name of the actor with the ID x in the database.             #
#  <party=*x*>                                                                 #
#     showing the name of the actor on slot x of the current party.            #
################################################################################

$imported = {} if $imported.nil?
$imported["HTML-tagging"] = [1,5,2]


STYLES = { "h1" => "<size=45><font=Cambria><b>|</b></font></size><down=40>",
           "h2" => "<big><b><font=Cambria>|</font></b></big><down=32>",
           "disabled" => "<color=disabled_color>|</color>",
           "highlight" => "<color=#eeee32>|</color>",
           "system" => "<color=system_color>|</color>" }

class Bitmap
  LINE_HEIGHT = Tidloc::Line_Height

#  draw_html(x, y, width, height, String[, textwrap?])
#  draw_html(Rect, String[, textwrap?])
  
  def draw_html(*args)
    if args[0].is_a?(Rect)
      x        = args[0].x
      y        = args[0].y
      width    = args[0].width
      height   = args[0].height
      str      = args[1]
      textwrap = args[2]==true ? args[2] : false
      @aling   = !textwrap && args[2] ? args[2] : 0
      @aling   = textwrap && args[3]  ? args[3] : 0
    else
      x        = args[0]
      y        = args[1]
      width    = args[2]
      height   = args[3]
      str      = args[4]
      textwrap = args[5]==true ? args[5] : false
      @aling   = !textwrap && args[5] ? args[5] : 0
      @aling   = textwrap && args[6]  ? args[6] : 0
    end
    str = str.to_s if str.is_a?(Numeric)
    @text = ""
    @max_width = width
    @aling = 0
    @max_height = height
    str = str.clone
    color = font.color.clone
    bold = font.bold
    italic = font.italic
    size = font.size
    name = font.name.clone
    shadow = false
    underlined = false
    opacity = 255
    str.gsub!(/<if=([0-9]+)>(.*)<else>(.*)<\/if>/) {$game_switches[$1.to_i] ? $2 : $3}
    str.gsub!(/<f=([0-9]+)>(.*)<\/f>/) {$game_switches[$1.to_i] ? $2 : ""}
    str.gsub!(/<v\[([0-9]+)\]>([0-9]+)>(.*)<\/v>/) {$game_variables[$1.to_i]>$2.to_f ? $3 : ""}
    str.gsub!(/<v\[([0-9]+)\]<([0-9]+)>(.*)<\/v>/) {$game_variables[$1.to_i]<$2.to_f ? $3 : ""}
    str.gsub!(/<var=([0-9]+)>/) {$game_variables[$1.to_i].to_s}
    str.gsub!(/<tv=([0-9]+)>/) {$game_temp.tidloc[:var][eval($1)].to_s}
    str.gsub!(/<tif=(.*)>(.*)<else>(.*)<\/tif>/) {$game_temp.tidloc[:var][eval($1)] ? $2 : $3}
    str.gsub!(/<eval=(.*)>/) {eval $1}
    str.gsub!(/{eval=(.*)}/) {eval $1}
    str.gsub!(/<eval>(.*)<\/eval>/) {eval $1}
    str.gsub!(/<style=([a-zA-Z0-9_]+)>(.*)<\/style>/) {
              STYLES.has_key?($1) ? STYLES[$1].sub("|", $2) : ""
              } if defined?(STYLES)
    str.gsub!(/<br>/) {"\n"}
    str.gsub!(/\\\\/) {"\00"}
    str.gsub!(/<b>/) {"\01"}
    str.gsub!(/<\/b>/) {"\02"}
    str.gsub!(/<i>/) {"\03"}
    str.gsub!(/<\/i>/) {"\04"}
    str.gsub!(/<color=(#?[0-9a-z_]+)>/) {"\05[#{$1}]"}
    str.gsub!(/<\/color>/) {"\06"}
    str.gsub!(/<shadow>/) {"\16"}
    str.gsub!(/<\/shadow>/) {"\17"}
    str.gsub!(/<small>/) {"\20"}
    str.gsub!(/<\/small>/) {"\21"}
    str.gsub!(/<big>/) {"\23"}
    str.gsub!(/<\/big>/) {"\21"}
    str.gsub!(/<size=(\d+)>/) {"\24[#{$1}]"}
    str.gsub!(/<\/size>/) {"\21"}
    str.gsub!(/<font=([\w\s]+)>/) {"\25[#{$1}]"}
    str.gsub!(/<\/font>/) {"\26"}
    str.gsub!(/<u>/) {"\27"}
    str.gsub!(/<\/u>/) {"\28"}
    str.gsub!(/<icon=([0-9]+)>/) {"\11[#{$1}]"}
    str.gsub!(/<img=(.*)>/) {"\31<Graphics/Pictures/#{$1}>"}
    str.gsub!(/<battler=(.*)>/) {"\31<Graphics/Battlers/#{$1}>"}
    str.gsub!(/<down=([0-9]+)>/) {"\22[#{$1}]"}
    str.gsub!(/<space=([0-9]+)>/) {"\140\01[#{$1}]"}
    str.gsub!(/<line>/) {"\07"}
    str.gsub!(/<actor=([0-9]+)>/) {$data_actors[$1.to_i].name}
    str.gsub!(/<party=([0-9]+)>/)  {$game_party.members[$1.to_i].name}
    str.gsub!(/<left>/)   {"\140\02"}
    str.gsub!(/<center>/) {"\140\03"}
    str.gsub!(/<right>/)  {"\140\04"}
    ix = 0
    iy = 0
    
    
    
    
    
    while ((c = str.slice!(/./m)) != nil)
      if c == "\00" # \\
        @text += "\\"
      elsif c == "\01" # <b>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.bold = true
      elsif c == "\02" #</b>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.bold = false
      elsif c == "\03" # <i>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.italic = true
      elsif c == "\04" # </i>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.italic = false
      elsif c == "\05" # <color=xxx>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        str.sub!(/\[(#?[0-9A-Za-z_]+)\]/, "")
        if $1[0] == '#'
          col = Color.decode($1)
        elsif $1.to_i != 0
          col = Window_Base.text_color($1.to_i)
        else
          col = Color.get($1)
        end
        font.color = col
      elsif c == "\06" # </color>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.color = color
      elsif c == "\16" # <shadow>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        shadow = true
      elsif c == "\17" # </shadow>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        shadow = false
      elsif c == "\20" # <small>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.size -= 5 if font.size > 10
      elsif c == "\21" # </small> </big> </size>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.size = size
      elsif c == "\23" # <big>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.size += 5 if font.size < 92
      elsif c == "\24" # <size=xx>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        str.sub!(/\[(\d+)\]/, "")
        newsize = $1.to_i
        font.size = newsize if newsize > 5 and newsize < 97
      elsif c == "\25" # <font=xxx>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        str.sub!(/\[([\w\s]*)\]/, "")
        font.name = $1 if Font.exist?($1)
      elsif c == "\26" # </font>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        font.name = name
      elsif c == "\27" # <u>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        underlined = true
      elsif c == "\28" # </u>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        underlined = false
      elsif c == "\11" #<icon=xxx>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        str.sub!(/\[(.*)\]/, "")
        temp = $1.to_i
        bitmap = Cache.system("Iconset")
        rect = Rect.new(temp % 16 * 24, temp / 16 * 24, 24, 24)
        blt(x+ix + 8, y+iy + LINE_HEIGHT/2 - 12, bitmap, rect, 255)
        ix += 24
      elsif c == "\31" # <img=xxx>,<battler=xxx>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        str.sub!(/<(.*)>/, "")
        temp=$1
        image=Cache.normal_bitmap(temp)
        iy += text_size("T").height
        blt((width-image.rect.width)/2, iy, image, image.rect)
        iy += image.rect.height
        ix = 0
      elsif c == "\22" # <down=xxx>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        str.sub!(/\[([0-9]+)\]/, "")
        iy += $1.to_i + text_size("T").height
        ix = 0
      elsif c == "\100" # blank space
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        ix += text_size("T").width
      elsif c == "\140" # additional commands
        c2 = str.slice!(/./m)
        if    c2 == "\01" # <space=xxx>
          t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
          str.sub!(/\[([0-9]+)\]/, "")
          ix += $1.to_i
          c = ""
        elsif c2 == "\02" # <left>
          @aling = 0
        elsif c2 == "\03" # <center>
          @aling = 1
        elsif c2 == "\04" # <right>
          @aling = 2
        end
      elsif c == "\07" # <line>
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        iy += text_size("T").height + 3
        fill_rect(16, iy, width-32, 2, font.color)
        fill_rect(16, iy, width-32, 2, Color.new(192, 192, 192, 156)) if shadow
        iy += 5
        ix = 0
      elsif c == "\n"
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        iy += text_size("T").height
        ix = 0
      elsif c == " " && textwrap
        t=write_text(x,ix,y,iy,textwrap,shadow,underlined);ix=t[0];iy=t[1]
        @text = " "
      else
        @text += c
      end
    end
    
    t=write_text(x,ix,y,iy,textwrap,shadow,underlined)
        ix=t[0]
        iy=t[1]
    
    @text = ""
    temp = text_size("T").height
    font.color = color
    font.bold = bold
    font.italic = italic
    font.size = size
    font.name = name
    return iy + temp
  end
  def Bitmap.html_decode(str)
    temp  = Bitmap.new(20,20)
    temp2 = temp.html_decode(str)
    temp.dispose
    return temp2
  end
  def html_decode(str)
    str = str.clone
    str.gsub!(/<if=([0-9]+)>(.*)<else>(.*)<\/if>/) {$game_switches[$1.to_i] ? $2 : $3}
    str.gsub!(/<f=([0-9]+)>(.*)<\/f>/) {$game_switches[$1.to_i] ? $2 : ""}
    str.gsub!(/<v\[([0-9]+)\]>([0-9]+)>(.*)<\/v>/) {$game_variables[$1.to_i]>$2.to_f ? $3 : ""}
    str.gsub!(/<v\[([0-9]+)\]<([0-9]+)>(.*)<\/v>/) {$game_variables[$1.to_i]<$2.to_f ? $3 : ""}
    str.gsub!(/<var=([0-9]+)>/) {$game_variables[$1.to_i].to_s}
    str.gsub!(/<tv=([0-9]+)>/) {$game_temp.tidloc[:var][$1.to_i].to_s}
    str.gsub!(/<tif=(.*)>(.*)<else>(.*)<\/tif>/) {$game_temp.tidloc[:var][eval($1)] ? $2 : $3}
    str.gsub!(/<eval=(.*)>/) {eval $1}
    str.gsub!(/{eval=(.*)}/) {eval $1}
    str.gsub!(/<eval>(.*)<\/eval>/) {eval $1}
    str.gsub!(/<style=([a-zA-Z0-9_]+)>(.*)<\/style>/) {""}
    str.gsub!(/<br>/) {"\n"}
    str.gsub!(/\\\\/) {"\\"}
    str.gsub!(/<b>/) {""}
    str.gsub!(/<\/b>/) {""}
    str.gsub!(/<i>/) {""}
    str.gsub!(/<\/i>/) {""}
    str.gsub!(/<color=(#?[0-9a-z_]+)>/) {""}
    str.gsub!(/<\/color>/) {""}
    str.gsub!(/<shadow>/) {""}
    str.gsub!(/<\/shadow>/) {""}
    str.gsub!(/<small>/) {""}
    str.gsub!(/<\/small>/) {""}
    str.gsub!(/<big>/) {""}
    str.gsub!(/<\/big>/) {""}
    str.gsub!(/<size=(\d+)>/) {""}
    str.gsub!(/<\/size>/) {""}
    str.gsub!(/<font=(.+)>/) {""}
    str.gsub!(/<\/font>/) {""}
    str.gsub!(/<u>/) {""}
    str.gsub!(/<\/u>/) {""}
    str.gsub!(/<icon=([0-9]+)>/) {""}
    str.gsub!(/<img=(.*)>/) {""}
    str.gsub!(/<battler=([a-zA-Z0-9_-]+)>/) {""}
    str.gsub!(/<down=([0-9]+)>/) {""}
    str.gsub!(/<space=([0-9]+)>/) {""}
    str.gsub!(/<line>/) {""}
    str.gsub!(/<actor=([0-9]+)>/) {$data_actors[$1.to_i].name}
    str.gsub!(/<party=([0-9]+)>/)  {$game_party.members[$1.to_i].name}
    str.gsub!(/<left>/) {""}
    str.gsub!(/<right>/) {""}
    str.gsub!(/<center>/) {""}
    return str
  end
  def write_text(x,ix,y,iy,textwrap,shadow,underlined)
    @text.rstrip! if @text.size > 1
    if (ix + x + 4 + text_size(@text).width > self.width) && textwrap
      ix  = 0
      iy += text_size("T").height
      @text.lstrip!
    end
    @text.lstrip! if ix == 0
    width = [text_size(@text).width+20,@max_width+10].min
    rect = Rect.new
    rect.x = x+ix+4
    rect.y = y+iy
    rect.width = width
    rect.height = [@max_height - iy,text_size(@text).height+8].min
    if shadow
      draw_shadow_text( rect, @text.reverse.chomp.reverse, @aling)
    else
      draw_text( rect, @text.reverse.chomp.reverse, @aling)
    end
    w = text_size(@text).width
    if underlined
      fill_rect(x+ix+4, y+iy+text_size(@text).height-4, w, 2, font.color)
    end
    @text = ""
    return [ix+w,iy]
  end
  def draw_shadow_text(*args)
    if args[0].is_a?(Rect)
      x      = args[0].x
      y      = args[0].y
      width  = args[0].width
      height = args[0].height
      str    = args[1]
      align  = args[2] ? args[2] : 0
    else
      x      = args[0]
      y      = args[1]
      width  = args[2]
      height = args[3]
      str    = args[4]
      align  = args[5] ? args[5] : 0
    end
    color = font.color.dup
    font.color = Color.new(192, 192, 192, 156)
    draw_text(x+2, y+2, width, height, str, align)
    font.color = color
    draw_text(x, y, width, height, str, align)
  end
end



class Color
  def Color.get(s)
    eval "Color.#{s}" rescue Color.white
  end
  def Color.decode(hex)
    return Color.decode(hex[1..hex.length]) if hex[0] == '#'
    hex.downcase!
    red = hex[0..1].hex
    green = hex[2..3].hex
    blue = hex[4..5].hex
    alpha = hex.length == 8 ? hex[6..7].hex : 255
    return Color.new(red, green, blue, alpha)
  end
  def Color.normal_color
    return Color.new(255, 255, 255, 255)
  end
  def Color.disabled_color
    return Color.new(255, 255, 255, 128)
  end
  def Color.system_color
    return Color.new(192, 224, 255, 255)
  end
  def Color.crisis_color
    return Color.new(255, 255, 64, 255)
  end
  def Color.knockout_color
    return Color.new(255, 64, 0)
  end
  def Color.white(alpha=255)
    return Color.new(255, 255, 255, alpha)
  end
  def Color.black(alpha=255)
    return Color.new(0, 0, 0, alpha)
  end
  def Color.red(alpha=255)
    return Color.new(255, 0, 0, alpha)
  end
  def Color.green(alpha=255)
    return Color.new(0, 255, 0, alpha)
  end
  def Color.blue(alpha=255)
    return Color.new(0, 0, 255, alpha)
  end
  def Color.yellow(alpha=255)
    return Color.new(255, 255, 0, alpha)
  end
  def Color.cyan(alpha=255)
    return Color.new(0, 255, 255, alpha)
  end
  def Color.magenta(alpha=255)
    return Color.new(255, 255, 0, alpha)
  end
  def Color.light_gray(alpha=255)
    return Color.new(192, 192, 192, alpha)
  end
  def Color.gray(alpha=255)
    return Color.new(128, 128, 128, alpha)
  end
  def Color.dark_gray(alpha=255)
    return Color.new(64, 64, 64, alpha)
  end
  def Color.pink(alpha=255)
    return Color.new(255, 175, 175, alpha)
  end
  def Color.orange(alpha=255)
    return Color.new(255, 200, 0, alpha)
  end
  def Color.gold(alpha=255)
    return Color.new(212, 175, 55, alpha)
  end
end



class Window_Base < Window
  def self.text_color(n)
    case n
    when 0
      return Color.new(255, 255, 255, 255)
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      return Color.white
    end
  end
  def draw_html(*args)
    contents.draw_html(*args)
  end
  def html_decode(*args)
    contents.html_decode(*args)
  end
  def draw_item_name(item, x, y, enabled = true, width = self.contents.width-16)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_html(x + 24, y, width-24-x, line_height, item.name)
  end
end

class Window_Command < Window_Selectable
  def draw_item(index)
    change_color(normal_color, command_enabled?(index))
    draw_html(item_rect_for_text(index), command_name(index), alignment)
  end
end