=begin
======================================
  Collectibles!
  Created by: Apellonyx
  Released: 8 April 2013
======================================
  Terms of Use:
    You are free to use this system however you wish, in commercial and non-
    commercial games alike. If you edit the script extensively, it is not
    necessary to credit me (since you clearly only used my code as a framework),
    but I would appreciate credit if it is used in its current form, or if only
    minor changes were made to the script.
======================================
  Support:
    While I am not wildly active, I usually log onto "rpgmakervxace.com" daily,
    so if you have any questions pertaining to the script, you can ask any
    questions there, in the topic in which this script was released. Just as a
    warning, though, I will not edit the script to make it compatible with any
    special menu systems, but I will try to fix bugs as they come up. If you
    find one, let me know, and I'll do my best to squash the thing.
======================================
  Changelog:
    v1.0: Initial release
======================================
  Requirements:
    None
======================================
  Description:
    This script adds a new window to the main menu that shows how many of a
    particular item the player has. It is meant to be used with collectible
    items and/or key items, and supports tracking for an unlimited amount of
    items (though it overlaps the command window when more than six items are
    being tracked).
======================================
  Instructions:
    Just add the database IDs for your collectibles into the ITEMIDS array. If
    using the default menu, the window will fit perfectly above the gold window.
    If using a custom menu script, you may need to adjust the WINXPOS, WINYPOS,
    and WINWIDTH to fit your menu.
======================================
=end
 
 
module AXCollect
 
  WINXPOS     = 0 # X position of the collectibles window
  WINYPOS     = 344 # Y position of the collectibles window
  WINWIDTH    = 160 # Width of the collectibles window
  WINTEXT     = 24 # Size of the text in the window (adjust if your item has
                   # a longer name than fits in the window)
  ITEMIDS     = [17, 18] # Database IDs for collectible items
 
end
 
class Scene_Menu < Scene_MenuBase
 
  alias collect_menu_start start
  def start
    create_collectibles_window
    collect_menu_start
  end
  def create_collectibles_window
    collectwinheight = AXCollect::ITEMIDS.size * 24
    collectwinypos = AXCollect::WINYPOS - collectwinheight
    @collect_menu = Window_Collectibles.new
    @collect_menu.x = AXCollect::WINXPOS
    @collect_menu.y = collectwinypos
    @collect_menu.z = 10000
  end
 
end
 
class Window_Collectibles < Window_Base
 
  def initialize
    collectwinheight2 = AXCollect::ITEMIDS.size * 24 + 24
    super(0, 0, AXCollect::WINWIDTH, collectwinheight2)
    refresh
  end
  def refresh
    contents.clear
    contents.font.size = AXCollect::WINTEXT
    itemids = AXCollect::ITEMIDS
    itemids.each_with_index do |itemid, index|
      draw_collectibles($data_items[itemid], -3, index * 24)
    end
  end
  def draw_collectibles(item, x, y, width = AXCollect::WINWIDTH - 22)
    draw_icon(item.icon_index, x, y - 1)
    change_color(system_color)
    draw_text(x + 24, y, width, line_height, item.name + "s")
    change_color(normal_color)
    draw_text(x, y, width, line_height, $game_party.item_number(item), 2)
  end
  def draw_item_name(item, x, y, enabled = true, width = 100)
  end
 
end