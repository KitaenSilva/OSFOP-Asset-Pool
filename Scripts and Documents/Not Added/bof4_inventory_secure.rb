# =============================================================================
# ♫ ~ Inventory Secure by TheoAllen ~ ♫
# Version : 1.2
# Contact : www.rpgmakerid.com
# =============================================================================
# Requires : N/A
# Rewrites method : N/A
# Alliases method : Game_Party initialize
# =============================================================================
# ♫ UPDATES :
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2013.02.23 - Fixed bugs in inventory check
#            - Secure inventory now also secure gold
# 2013.02.21 - Added merge secured inventory and secured inventory check
#            - Fixed some typos and bugs
# 2013.02.20 - Started and Finished script
#
# =============================================================================
# ♫ DESCRIPTION :
# This script allow you to save current party's inventory when you're going to
# switch party members into another team members for storytelling purposes.
#
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# ♫ INSTRUCTION :
# Put this script below material but above main in script editor. Don't forget
# to save.
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# ♫ HOW TO USE :
# Type these all in script call
# - secure_inv(n)       = Secure party's inventory which "n" is an index where  
#                         you put the secured inventory.
# - get_inv(n)          = Get inventory from "n" index. It replaces the current
#                         party's inventory.
# - merge_inv(n)        = Merge secured inventory from "n" index to party's
#                         inventory.
# - inventory_exist?(n) = check avalaibility of secured inventory. can be used
#                         in conditional branch through script call
# =============================================================================
# ♫ TERMS OF USE :
# - Credit me, TheoAllen.
# - You may use and edit this script both for commercial and non-commercial or
#   even adult game as long as u don't claim it yours.
# - I'll be glad if you give me a free copy of your game if you use this script
#   in your commercial project.
# =============================================================================
#
# =============================================================================
# ♫ No custom configuration avalaible ~ ♫
# ♫ Do not edit unless you know what to do ~ ♫
# =============================================================================
 
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ♫ Aliased initialize ~
  #--------------------------------------------------------------------------  
   alias theo_inv_secure_init initialize
   def initialize
     theo_inv_secure_init
     init_all_bags
   end
  #--------------------------------------------------------------------------
  # ♫ Initialize all bags ~
  #--------------------------------------------------------------------------
   def init_all_bags
     @item_bags = []
     @weapon_bags = []
     @armor_bags = []
     @gold_bags = []
   end
  #--------------------------------------------------------------------------
  # ♫ Secure all inventories ~
  #--------------------------------------------------------------------------
   def secure_all(index)
     secure_items(index)
     secure_weapons(index)
     secure_armors(index)
     secure_gold(index)
   end
  #--------------------------------------------------------------------------
  # ♫ Secure items ~
  #--------------------------------------------------------------------------
   def secure_items(index)
     @item_bags[index] = @items.clone
     @items.clear
   end
  #--------------------------------------------------------------------------
  # ♫ Secure weapons ~
  #--------------------------------------------------------------------------
   def secure_weapons(index)
     @weapon_bags[index] = @weapons.clone
     @weapons.clear
   end
  #--------------------------------------------------------------------------
  # ♫ Secure armors ~
  #--------------------------------------------------------------------------
   def secure_armors(index)
     @armor_bags[index] = @armors.clone
     @armors.clear
   end
  #--------------------------------------------------------------------------
  # ♫ Secure gold ~
  #--------------------------------------------------------------------------
   def secure_gold(index)
     @gold_bags[index] = @gold
     @gold = 0
   end  
  #--------------------------------------------------------------------------
  # ♫ Get all secured inventories ~
  #--------------------------------------------------------------------------
   def get_all(index)
     get_items(index)
     get_weapons(index)
     get_armors(index)
     get_gold(index)
   end
  #--------------------------------------------------------------------------
  # ♫ Get secured items ~
  #--------------------------------------------------------------------------
   def get_items(index)
     item_bags_exist?(index) ? @items = @item_bags[index].dup : @items = {}
     @item_bags[index].clear
   end
  #--------------------------------------------------------------------------
  # ♫ Get secured weapons ~
  #--------------------------------------------------------------------------
   def get_weapons(index)
     weapon_bags_exist?(index) ? @weapons = @weapon_bags[index].dup : @weapons = {}
     @weapon_bags[index].clear
   end
  #--------------------------------------------------------------------------
  # ♫ Get secured armors ~
  #--------------------------------------------------------------------------
   def get_armors(index)
     armor_bags_exist?(index) ? @armors = @armor_bags[index].dup : @armors = {}
     @armor_bags[index].clear
   end
  #--------------------------------------------------------------------------
  # ♫ Get secured gold ~
  #--------------------------------------------------------------------------
  def get_gold(index)
    gold_bags_exist?(index) ? @gold = @gold_bags[index] : @gold = 0
    @gold_bags[index] = 0
  end
  #--------------------------------------------------------------------------
  # ♫ Merge secured inventories to current inventories ~
  #--------------------------------------------------------------------------
   def merge_all(index)
     merge_items(index)
     merge_weapons(index)
     merge_armors(index)
     merge_gold(index)
   end
  #--------------------------------------------------------------------------
  # ♫ Merge secured items ~
  #--------------------------------------------------------------------------
   def merge_items(index)
     @item_bags[index].each_key do |id|
       gain_item($data_items[id], @item_bags[index][id]) if item_bags_exist?(index)
     end
     @item_bags[index] = {}
   end
  #--------------------------------------------------------------------------
  # ♫ Merge secured weapons ~
  #--------------------------------------------------------------------------
   def merge_weapons(index)
     @weapon_bags[index].each_key do |id|
       gain_item($data_weapons[id], @weapon_bags[index][id])if weapon_bags_exist?(index)
     end
     @weapon_bags[index] = {}
   end
  #--------------------------------------------------------------------------
  # ♫ Merge secured armors ~
  #--------------------------------------------------------------------------
   def merge_armors(index)
     @armor_bags[index].each_key do |id|
       gain_item($data_armors[id], @armor_bags[index][id]) if armor_bags_exist?(index)
     end
     @armor_bags[index] = {}
   end
  #--------------------------------------------------------------------------
  # ♫ Merge secured gold ~
  #--------------------------------------------------------------------------
   def merge_gold(index)
     gain_gold(@gold_bags[index]) if gold_bags_exist?(index)
     @gold_bags[index] = 0
   end
  #--------------------------------------------------------------------------
  # ♫ Return true if secured inventory is avalaible
  #--------------------------------------------------------------------------
   def inventory_exist?(index)
     return true if item_bags_exist?(index) ||
     weapon_bags_exist?(index) ||
     armor_bags_exist?(index)
     return false
   end
  #--------------------------------------------------------------------------
  # ♫ Return true if secured item is avalaible
  #--------------------------------------------------------------------------
   def item_bags_exist?(index)
     return true if index <= @item_bags.size-1 && !@item_bags[index].nil? && check_values(@item_bags[index])
     return false
   end
  #--------------------------------------------------------------------------
  # ♫ Return true if secured weapon is avalaible
  #--------------------------------------------------------------------------
   def weapon_bags_exist?(index)
     return true if index <= @weapon_bags.size-1 && !@weapon_bags[index].nil? && check_values(@weapon_bags[index])
     return false
   end
  #--------------------------------------------------------------------------
  # ♫ Return true if secured armor is avalaible
  #--------------------------------------------------------------------------
   def armor_bags_exist?(index)
     return true if index <= @armor_bags.size-1 && !@armor_bags[index].nil? && check_values(@armor_bags[index])
     return false
   end
  #--------------------------------------------------------------------------
  # ♫ Return true if secured gold is avalaible ~
  #--------------------------------------------------------------------------
   def gold_bags_exist?(index)
     return true if index <= @gold_bags.size-1 && !@gold_bags[index].nil? && @gold_bags[index] > 0
     return false
   end
  #--------------------------------------------------------------------------
  # ♫ Check avalaible items. Returns FALSE if all items are 0
  #--------------------------------------------------------------------------  
   def check_values(bags)
     values = bags.values
     return values.any? {|value| value > 0}
   end
 end
# =============================================================================
# ♫ End of Game_Party class ♫
# =============================================================================
#
# These methods are to simplify script call
#
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 def secure_inv(index)
   $game_party.secure_all(convert_index(index))
 end
 
 def get_inv(index)
   $game_party.get_all(convert_index(index))
 end
 
 def merge_inv(index)
   $game_party.merge_all(convert_index(index))
 end
 
 def inventory_exist?(index)
   $game_party.inventory_exist?(convert_index(index))
 end
 
 def convert_index(index)
   return 0 if index < 0
   return index
 end
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=