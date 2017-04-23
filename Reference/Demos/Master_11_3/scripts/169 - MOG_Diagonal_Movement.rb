#==============================================================================
# +++ MOG - Simple Diagonal Movement (v1.3) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# Sistema simples de movimento na diagonal.
#==============================================================================

#==============================================================================
# ■ Diagonal Movement
#==============================================================================
class Game_Player < Game_Character  
  
  #--------------------------------------------------------------------------
  # ● Move By Input
  #--------------------------------------------------------------------------    
  def move_by_input
      return if !movable?
      return if $game_map.interpreter.running?
      case Input.dir8
           when 2,4,6,8; move_straight(Input.dir4)
           when 1 ;  move_diagonal_straight(4, 2)
           when 3 ;  move_diagonal_straight(6, 2)
           when 7 ;  move_diagonal_straight(4, 8)
           when 9 ;  move_diagonal_straight(6, 8)
      end
  end

  #--------------------------------------------------------------------------
  # ● Move Diagonal Straight
  #--------------------------------------------------------------------------      
  def move_diagonal_straight(x,y)
      move_diagonal(x, y)
      return if moving?
      move_straight(x) ; move_straight(y)
  end
    
end

$mog_rgss3_simple_diagonal_movement = true