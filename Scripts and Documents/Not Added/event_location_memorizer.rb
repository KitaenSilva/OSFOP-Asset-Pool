#==================================================================
# Event Map Memorizer
# Autor: Raizen
# Comunidade : centrorpg.com
# Compatibilidade: RMVXAce
#==================================================================
 
# Description: The script allows that the event positions are saved,
# In the teleport, events on the map will be in the same position they were
# when they left that place.
 
# The script is configured automatically to save and load those positions
# In the moment of the teleport.
 
# To save manually
# Script Call: $game_map.save_event_positions
 
# To load manually
# Script Call: $game_map.load_event_positions
 
# To clear the save positions of a certain map
# where map_id is the id of the map.
# Script Call: $game_map.clear_event_positions(map_id)
 
module Lune_event_pos
# Switch that when it is on, it deactivates the
# automatic save, use it for rooms with puzzles
# for example.
Switch = 1
end
 
 
#==================================================================
#==================================================================
#==================== Here starts the script ======================#
 
#=================================================================#
#====================  Alias methods =============================#
# reserve_transfer     => Game_Player
# initialize           => Game_Map
# perform_transfer     => Game_Player
#=================================================================#
#========================  New methods ===========================#
# save_event_positions    => Game_Map
# load_event_positions    => Game_Map
# clear_event_positions   => Game_Map
#=================================================================#
#=================================================================#
 
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  Esta classe gerencia o mapa. Inclui funções de rolagem e definição de
# passagens. A instância desta classe é referenciada por $game_map.
#==============================================================================
class Game_Map
alias :lune_memorize_initialize :initialize
  #--------------------------------------------------------------------------
  # * Inicialização das variáveis
  #--------------------------------------------------------------------------
  def initialize
    lune_memorize_initialize
    @memorize_pos = []
  end
  #--------------------------------------------------------------------------
  # * Memorização das posições
  #--------------------------------------------------------------------------
  def save_event_positions
    @memorize_pos[@map_id] = []
    $game_map.events.values.select {|event| @memorize_pos[@map_id][event.id] = [event.x, event.y]}
  end
  #--------------------------------------------------------------------------
  # * Carregamento das posições
  #--------------------------------------------------------------------------
  def load_event_positions
    return if @memorize_pos[@map_id] == nil
    $game_map.events.values.select {|event| event.moveto(@memorize_pos[@map_id][event.id][0], @memorize_pos[@map_id][event.id][1])}
  end
  def clear_event_positions(map_id)
    @memorize_pos[map_id] == nil
  end
end
 
 
#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  Esta classe gerencia o jogador.
# A instância desta classe é referenciada por $game_player.
#==============================================================================
class Game_Player < Game_Character
alias lune_perform_transfer perform_transfer
alias lune_perform_reserve reserve_transfer
  #--------------------------------------------------------------------------
  # * Carregando as posições
  #--------------------------------------------------------------------------
  def perform_transfer
    lune_perform_transfer
    $game_map.load_event_positions unless $game_switches[Lune_event_pos::Switch]
  end
  #--------------------------------------------------------------------------
  # * Salvando as posições
  #--------------------------------------------------------------------------
  def reserve_transfer(map_id, x, y, d = 2)
    lune_perform_reserve(map_id, x, y, d = 2)
    $game_map.save_event_positions unless $game_switches[Lune_event_pos::Switch]
  end
end