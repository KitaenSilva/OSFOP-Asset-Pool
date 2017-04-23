#Detailed Equip Status v1.0
#----------#
#Features: Adds MHP and MMP to equip status, as well as showing gains
#
#Usage:    Plug and play
#
#----------#
#-- Script by: V.M of D.T
#
#- Questions or comments can be:
#    posted on the thread for the script
#    given by email: sumptuaryspade@live.ca
#    provided on facebook: http://www.facebook.com/DaimoniousTailsGames
#   All my other scripts and projects can be found here: http://daimonioustails.weebly.com/
#
#- Free to use in any project with credit given, donations always welcome!

class Window_EquipStatus < Window_Base
  def line_height
    return 18
  end
  def window_height
    24*8
  end
  def visible_line_number
    return 9
  end
  def refresh
    contents.clear
    contents.font.size = 18
    draw_actor_name(@actor, 36, 0) if @actor
    8.times {|i| draw_item(0, (line_height * (1 + i)), i) }
  end
  def draw_item(x, y, param_id)
    draw_param_name(x + 4, y, param_id)
    draw_current_param(x + 60, y, param_id) if @actor
    draw_right_arrow(x + 96, y)
    draw_new_param(x + 120, y, param_id) if @temp_actor
    draw_param_change(x + 152, y, param_id) if @temp_actor
  end
  def draw_param_name(x, y, param_id)
    change_color(system_color)
    draw_text(x, y, 80, line_height, Vocab::param(param_id))
  end
  def draw_current_param(x, y, param_id)
    change_color(normal_color)
    draw_text(x, y, 32, line_height, @actor.param(param_id), 2)
  end
  def draw_new_param(x, y, param_id)
    new_value = @temp_actor.param(param_id)
    change_color(param_change_color(new_value - @actor.param(param_id)))
    draw_text(x, y, 32, line_height, new_value, 2)
  end
  def draw_param_change(x, y, param_id)
    value = @temp_actor.param(param_id) - @actor.param(param_id)
    change_color(param_change_color(value))
    if value > 0
      text = "+" + value.to_s
    elsif value < 0
      text = value.to_s
    else
      text = ""
    end
    draw_text(x, y, 32, line_height, text, 2)
  end
end
