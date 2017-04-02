#------------------------------------------------------------------------------#
#  Galv's New Item Indication
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.5
#------------------------------------------------------------------------------#
#  2014-01-05 - Version 1.5 - compatibility fix
#  2013-07-16 - Version 1.4 - made key items work
#  2013-03-05 - Version 1.3 - fixed bug when all items are new when battle exit
#  2013-03-03 - Version 1.2 - added script call to manually remove 'new' images
#                           - fixed unequipping item creating 'new' images
#  2013-03-03 - Version 1.1 - fixed method 2 new not appearing for drops
#  2013-03-03 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  Adds a 'new' image on items in the inventory that the player has recently
#  acquired. There are 2 methods for you to chose from as to when this image
#  appears and when it is removed and no longer counted as new.
#------------------------------------------------------------------------------#
#  SCRIPT CALL
#------------------------------------------------------------------------------#
#
#  clear_new(type)      # Manually removes 'new' images from selected type
#                       # type can be one of the following
#                       # :all    :item     :weapon    :armor
#------------------------------------------------------------------------------#
#  EXAMPLE:
#  clear_new(:item)     # all 'new' image on items will be cleared
#  clear_new(:all)      # all 'new' images on everything will be cleared
#------------------------------------------------------------------------------#
   
($imported ||= {})["Galv_New_Item_Indicator"] = true
module Galv_Nitem
     
#------------------------------------------------------------------------------# 
#  SETUP OPTIONS
#------------------------------------------------------------------------------#
   
  IMAGE = "new_indicator"    # Image located in /Graphics/System/
     
  METHOD = 2     # METHOD option can be 1 or 2 (see below)
   
#------------------------------------------------------------------------------# 
#
#   1: The 'new' image appears on items that the player hasn't seen before and
#      is only removed when the player moves the cursor over them (from any
#      scene)
#
#   2: The new image appears for items that are picked up and are removed
#      when the player leaves the item scene OR cursors over the item.
#      Any items picked up again will re-add the 'new' image for the player to
#      see what items they picked up recently. (So if you already had 4 potions
#      and pick up another, potions would have 'new' image again).
#
#------------------------------------------------------------------------------# 
#  END SETUP OPTIONS
#------------------------------------------------------------------------------#
   
end
   
class Game_Interpreter
  def clear_new(type)
    if type == :all
      $game_party.nitems[:weapon] = []
      $game_party.nitems[:armor] = []
      $game_party.nitems[:item] = []
    else
      $game_party.nitems[type] = []
    end
  end
end # Game_Interpreter
   
   
module Galv_GetCat
  def get_category(item)
    if item.is_a?(RPG::Item)
      return :item
    elsif item.is_a?(RPG::Weapon)
      return :weapon
    elsif item.is_a?(RPG::Armor)
      return :armor
    else
      return :none
    end
  end
end # Galv_GetCat
   
   
class Window_Help < Window_Base
  include Galv_GetCat
     
  alias galv_nitem_wh_set_item set_item
  def set_item(item)
    galv_nitem_wh_set_item(item)
    add_to_known_items(item)
  end
     
  def add_to_known_items(item)
    category = get_category(item)
    return if category == :none
    if !$game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 1
      $game_party.nitems[category][item.id] = true
    elsif $game_party.nitems[category][item.id] && Galv_Nitem::METHOD == 2
      $game_party.nitems[category][item.id] = false
    end
    SceneManager.scene.refresh_new
  end
end # Window_Help < Window_Base
   
   
class Game_Party < Game_Unit
  attr_accessor :nitems
  include Galv_GetCat
     
  alias galv_nitem_gp_initialize initialize
  def initialize
    @nitems = {:item=>[],:weapon=>[],:armor=>[]}
    galv_nitem_gp_initialize
  end
     
  alias galv_nitem_gp_gain_item gain_item
  def gain_item(item, amount, include_equip = false)
    galv_nitem_gp_gain_item(item, amount, include_equip)
    if Galv_Nitem::METHOD == 2 && item
      last_number = item_number(item)
      new_number = last_number + amount
       
      if [[new_number, 0].max, max_item_number(item)].min > last_number
        cat = get_category(item)
        return if cat == :none
        $game_party.nitems[cat][item.id] = true
      end
    end
  end
end # Game_Party < Game_Unit
   
   
class Window_ItemList < Window_Selectable
  include Galv_GetCat
     
  alias galv_nitem_wi_draw_item draw_item
  def draw_item(index)
    galv_nitem_wi_draw_item(index)
    item = @data[index]
    return if item.nil?
       
    cat = get_category(item)
    return if cat == :none
    rect = item_rect(index)
    if Galv_Nitem::METHOD == 1 && !$game_party.nitems[cat][item.id] ||
        Galv_Nitem::METHOD == 2 && $game_party.nitems[cat][item.id]
      draw_item_new(item, rect.x, rect.y)
    end
  end
     
  def draw_item_new(item, x, y)
    bitmap = Cache.system(Galv_Nitem::IMAGE)
    rect = Rect.new(0, 0, 24, 24)
    contents.blt(x, y, bitmap, rect, 255)
  end
end # Window_ItemList < Window_Selectable
   
   
class Window_EquipItem
  # If Yanfly's Equip Engine:
  if $imported["YEA-AceEquipEngine"]
    def draw_item(index)
      item = @data[index]
      rect = item_rect(index)
      rect.width -= 4
      if item.nil?
        draw_remove_equip(rect)
        return
      end
      dw = contents.width - rect.x - 24
      draw_item_name(item, rect.x, rect.y, enable?(item), dw)
      draw_item_number(rect, item)
      cat = get_category(item)
      return if cat == :none
      if !$game_party.nitems[cat][item.id] && Galv_Nitem::METHOD == 1 ||
          $game_party.nitems[cat][item.id] && Galv_Nitem::METHOD == 2
        rect = item_rect(index)
        draw_item_new(item, rect.x, rect.y)
      end
    end
  end
end # Window_EquipItem (For Yanfly's Equip Script)
   
   
class Scene_Base
  def refresh_new
    @item_window.refresh if @item_window
  end
     
  alias galv_nitem_sb_return_scene return_scene
  def return_scene
    clear_new if Galv_Nitem::METHOD == 2
    galv_nitem_sb_return_scene
  end
     
  def clear_new
    if SceneManager.scene_is?(Scene_Item)
      $game_party.nitems[:weapon] = []
      $game_party.nitems[:armor] = []
      $game_party.nitems[:item] = []
    end
  end
end # Scene_Base
   
   
class Game_Actor < Game_Battler
  include Galv_GetCat
     
  # OVERWRITE
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    unequipped_not_new(old_item)
    return true
  end
     
  def unequipped_not_new(item)
    cat = get_category(item)
    return if cat == :none || Galv_Nitem::METHOD == 1
    $game_party.nitems[cat][item.id] = false
  end
end # Game_Actor < Game_Battler