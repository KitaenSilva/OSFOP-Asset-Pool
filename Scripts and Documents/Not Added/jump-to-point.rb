class Game_Character
  # --------------------------------------------------------------------------
  # Jump to point/coordinate. Coz, I hate to calculate
  # --------------------------------------------------------------------------
  def jump_to_point(xpos, ypos)
    x_dist = xpos - x
    y_dist = ypos - y
    jump(x_dist, y_dist)
  end
  
end 