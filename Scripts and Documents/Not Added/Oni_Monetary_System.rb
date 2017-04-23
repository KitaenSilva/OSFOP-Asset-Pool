=begin
#===============================================================================
# Spike's Engine - Monetary System
#
# Version: 1.01
# Author: Chris Barnett
# Date: March 26th, 2012
# Credit: Give credit where credit is due :)
#===============================================================================
# Description:
#
# This script displays currency values in terms of Copper, Silver, Gold, and
# Platinum coins. It doesn't actually change the way gold works in any way,
# only the way it is displayed.
#===============================================================================
# Instructions:
#
# Place this script above Main and below default scripts in the Script Editor.
# If you plan to integrate with Modern Algebra's Special Message Codes it
# would probably be wise to place this this script above it.
#
# You'll need to insert images for the coins into your IconSet resource. At
# the moment the script requires the coin's icon indices to be in sequential
# order, starting with the most valuable. I may unwrap the for loop if there
# seems to be a need to assign non sequential icon indices.
#
# You will then need to set ICON to the icon index of the least valuable coin.
#
# To integrate with Modern Algebra's Special Message Codes, Just paste
# the lines below into the icons section of convert_escape_characters
#
result.gsub!(/\iSMC/i) { "\i\[#{::SPIKE::GOLD::ICON}\]" rescue "" }
result.gsub!(/\iSMS/i) { "\i\[#{::SPIKE::GOLD::ICON-1}\]" rescue "" }
result.gsub!(/\iSMG/i) { "\i\[#{::SPIKE::GOLD::ICON-2}\]" rescue "" }
result.gsub!(/\iSMP/i) { "\i\[#{::SPIKE::GOLD::ICON-3}\]" rescue "" }
#
# To call up the icons in a message box use the following escape sequences.
#
# \iSMC for Copper
# \iSMS for Silver
# \iSMG for Gold
# \iSMP for Platinum
#
# NOTE!!! If you have any issues with this, please don't bother Modern Algebra
# about it. He already spent his time writing Special Message Codes and
# probably a fair amount of time answering questions about it. If you need
# assistance, please contact me directly. I am plenty willing to help.
#===============================================================================
# Known Bugs:
#
# A compatibility issue with Yanfly's Ace Save Engine has been reported
# but not yet confirmed. If you experience troubles, please let me know.
#===============================================================================
=end

$imported = {} if $imported.nil?
$imported["SE-Money"] = true

module SPIKE
module GOLD
BATTLE_ALIGN = 1 # Change to non 0 to push icons to the right when receiving loot in battle
ICON_POS = 4 # Increase to push icons right, decrease to pull left
TEXT_POS = 0 # Increase to push text right, decrease to pull left
OFFSET = -33 # Decrease to spread coins apart, increase to draw them closer
ICON = 191 # Change this to the icon index of the least valuable coin
HEIGHT = 0 # Increase to raise coins, decrease to lower
end
end

class Window_Base < Window
def draw_currency_value(value, unit, x, y, width)
value *= -1 if value < 0
pos = ::SPIKE::GOLD::ICON_POS
for i in 0..3
change = value % 100
value = value / 100
draw_icon(SPIKE::GOLD::ICON - i,width + pos + SPIKE::GOLD::OFFSET, y - SPIKE::GOLD::HEIGHT)
draw_text(x + SPIKE::GOLD::TEXT_POS, y, width + pos, line_height, change, 2)
pos += ::SPIKE::GOLD::OFFSET
end
end
end

class Game_Party < Game_Unit
def max_gold
return 99999999
end
def gain_gold(amount)
@gold = [[@gold + amount, 0].max, max_gold].min
end
def gold
return @gold
end
end

class Window_ShopBuy < Window_Selectable
def draw_currency_value(value, unit, x, y, width)
value *= -1 if value < 0
pos = SPIKE::GOLD::ICON_POS
for i in 0..3
change = value % 100
value = value / 100
if change != 0
draw_icon(SPIKE::GOLD::ICON - i,width + pos + SPIKE::GOLD::OFFSET, y - SPIKE::GOLD::HEIGHT)
draw_text(x + SPIKE::GOLD::TEXT_POS, y, width + pos, line_height, change, 2)
pos += SPIKE::GOLD::OFFSET
end
end
end
def draw_item(index)
item = @data[index]
rect = item_rect(index)
draw_item_name(item, rect.x, rect.y, enable?(item))
draw_currency_value(price(item), Vocab::currency_unit, rect.x + 4, rect.y, contents.width - SPIKE::GOLD::ICON_POS - 8)
end
end

class Window_ShopNumber < Window_Selectable
def draw_currency_value(value, unit, x, y, width)
value *= -1 if value < 0
pos = SPIKE::GOLD::ICON_POS
for i in 0..3
change = value % 100
value = value / 100
if change != 0
draw_icon(SPIKE::GOLD::ICON - i,width + pos + SPIKE::GOLD::OFFSET, y - SPIKE::GOLD::HEIGHT)
draw_text(x + SPIKE::GOLD::TEXT_POS, y, width + pos, line_height, change, 2)
pos += ::SPIKE::GOLD::OFFSET
end
end
end
end

module BattleManager
def self.gain_gold
if $game_troop.gold_total > 0
value = $game_troop.gold_total
result = ''
for i in 0..3
change = value % 100
value = value / 100
if change != 0
if SPIKE::GOLD::BATTLE_ALIGN == 0
result = ('\i[' + (::SPIKE::GOLD::ICON - i).to_s + ']' + change.to_s + ' ') + result
else
result = (change.to_s + '\i[' + (::SPIKE::GOLD::ICON - i).to_s + '] ') + result
end
end
end
$game_message.add('Found ' + result + '\.')
$game_party.gain_gold($game_troop.gold_total)
end
wait_for_message
end
end

# Uncomment for compatability with Yanfly's Ace Save Engine
#class Window_FileStatus < Window_Base
# def draw_save_gold(dx, dy, dw)
# return if @header[:party].nil?
# draw_currency_value(@header[:party].gold.group.to_i, Vocab::currency_unit, + SPIKE::GOLD::ICON_POS, dy, contents.width - SPIKE::GOLD::ICON_POS - 8)
# end
#end

class Game_Interpreter; include SPIKE::GOLD;
end