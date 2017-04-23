#============================================================================
# Property System v1.3
# By Emerald
#----------------------------------------------------------------------------
# You're free to use the script for any game, as long as you give credits
#----------------------------------------------------------------------------
# Version History
# 1.0 -> Started the script. Added all basic functions.
# 1.1 -> Added conditions and more control over the menu option.
# 1.2 -> Bugfixes.
# 1.3 -> Added an option to change variables and switch on upgrades or renting
#		out.
#----------------------------------------------------------------------------
# This script creates a new scene in which the player can buy "houses", like in
# Fable. You can also make the player able to buy other stuff, like a pizza
# stall. Just change some of the configurations! Note however, that the player
# can always rent the stuff to "other people".
#
# Instructions:
#
# Just as always, put this script between ▼ Materials and ▼ Main (*sigh*)
#
# Next to the configurations, make a new Common Event. Set it to Parallel Process,
# and select a switch which must be on before it starts running. Put anything
# you want to happen when the player receives rent for a property in the common
# event, but whatever you do, always add a script call with:
#
# $property_variables.get_rent(property_id)
# --------
# The player receives rent for the property with the id property_id. Note that
# this only happens if the player has rented out the house. Can also easily be
# used for variables.
#
# $property_variables.get_rent_all
# --------
# Almost the same as the above. However, this one make a list itself of ALL
# properties which the player has rented out. Also returns the total rent the
# player gains.
#
#
# As for the configurations:
#
# Properties
# ----------
# This is a hash containing all data needed to set-up the properties. This hash
# must start at 1. The id is the key in the hash, substracted by one.
# i.e:
# Property 1 => [......] has the id 0.
# Property 234 => [.....] has the id 233.
#
# Every key contains 5 arrays. One containing standard data. One containing
# upgrade prices. One containing the rent gained. One containing conditions
# for the property to appear in the list of properties while managing them.
# One containing conditions to be able to manage the property.
#
# Standard data syntax:
# ["name", "picture_name", standard_price, price_mod, standard_sell_price,
#  sell_price_mod],
# name = the name of the property as displayed in the menu. Don't forget the "'s!
# picture_name = the filename of the picutre displayed while having the
#				property selected in the menu. Don't forget the exstension! Also
#				note that the picture can't be larger than 174x174, or it will be
#				cut off.
# standard_price = minimum price of the property.
# price_mod = max value of the random added price. You only have to specify it
#			 if you use RANDOMIZE_PRICES.
# standard_sell_price = standard price for which the property can be sold. Can be
#					   replaced by FORMULA_SELL_PRICE.
# sell_price_mod = same as price_mod but for the sell price. Again, only if you
#				  use RANDOMIZE_PRICES.
#
# Upgrade data syntax:
# [upgrade_cost, upgrade_mod],
# This one is a slightly tricky one. If RANDOMIZE_PRICES for upgrades is false,
# all elements are the cost for every following upgrade. However, if it is true,
# you need to at a upgrade_mod for every upgrade. So with 2 upgrades it would
# either be:
# [upgrade1_cost, upgrade2_cost],
# OR
# [upgrade1_cost, upgrade2_cost, upgrade1_mod, upgrade2_mod],
#
# Rent data syntax:
# [gained_rent, gained_rent_mod],
# Practically the same as the upgrades. HOWEVER, you need to add 1/2 extra
# elements for when the property HAS NOT been upgraded yet.
#
# For the syntaxes of the next two arrays, see CONDITION VALUES at the end of
# the instructions.
#
# Upgrade and Rent Out Switch/Variable changes syntax: (row 6 and 7)
# Row 6 applies to upgrading/buying properties.
# Row 7 applies to renting propertys.
# Basic syntax is [[changes for no upgrades], [changes ugrapde 1], and so on]
# Seperate changes with a comma.
# ["S", switch ID, result]
# For standard switches. Result either true or false. "S" to indicate a switch.
# Switch ID is self-explanatiory.
#
# ["V", change, variable ID, result]
# For variables. "V" to indicate variable. Affects variable ID. For change:
# "=" / Variable becomes result.
# "+" / Result is added to the variable.
# "-" / Result is substracted from the variable.
# "*" / Variable is multiplied by result.
# "/" / Variable is divided by result.
# "%" / First, variable is divided by result. Then, the remainder is stored in
# the variable. So for result = 7 and variable = 16 you get:
# 16 / 7 = 2, rest 2
#				  ^ becomes new data.
#
# ["SS", [map id, event id, key], result]
# Practically same as "S", only this affects self switches. Event ID for the
# event, map ID of the map the event is on and key is either "A", "B", "C" or "D".
# Switch becomes result.
#
# When selling a property (with NO_CHANGE_ON_SELL false) or cancelling the rent of
# a property, all the effects of the all upgrades/current upgrade respectively
# will be reversed. THIS, HOWEVER, EXCLUDES ["V", "=" and ["V", "%" since they
# the previous data is lost as soon as the variable changes.
#
# RANDOMIZE_PRICES = [key1, key2, key3, key4]
# If a key is set to true, variables belonging to that key will receive a
# randomized bonus.
# Key1 = buy prices
# Key2 = sell prices
# Key3 = upgrade costs
# Key4 = gained rent
#
# PERCENTAGE_MODS = [key1, key2, key3, key4]
# Only work if RANDOMIZE_PRICES is on. This makes the random value a bonus
# in percentages. Note that if the mod is negative it is a reduction, if it is
# positive, it's a bonus. So to get max. 120% of the normal price, you only have
# to set the random mods to 20.
#
# FORMULA_SELL_PRICE = [use?, "formula", addition_to_upgrades]
# Set use? to true if you want to use a formula for the sell price instead of
# 1/2 set variables. You can use the following:
# script calls
# buy_price -> price of the property in-game (includes changes).
# standard_buy_price -> price set in Properties
# standard_buy_mod -> random price amount set in Properties
# standard_sell_price -> sell price set in Properties
# standard_sell_mod -> random sell price amount set in Properties
# upgrades -> current amount of upgrades. 0 if none. addition_to_upgrades is a
#			 bonus value to this variable (used if i.e. this variable should
#			 always be > 0).
# rent -> the current rent gained from the property
# i -> the id of the property
#
# VARIABLE = variable_id
# Variable to store rent data in if $property_variables.get_rent_all has been
# used. If you don't access the variable from the command while making events
# (so either you only use \v[x], or change the variable by use of script calls)
# the ID can be larger than 5000.
#
# OWNED_ICON = icon_id
# Icon to be shown if the player owns a property.
#
# CANNOT_MANAGE_COLOR = text_colour_id
# If you can't manage a property, but it's still shown in the list, the color
# of its name change to this text color.
#
# IMAGE_FOLDER = "folder(s)"
# The path of the folder where the pictures for the properties are located.
# Start in the folder of your game. Always make sure there's a / at the end.
#
# STATE_RENTED_OUT = "state"
# If the house is rented out, state is displayed as its current state.
#
# STATE_OWNED = "state"
# Same as above.
#
# STATE_BUYABLE = "state"
# Same as above.
#
# RENT_GAINED = "vocab"
# The vocab for the rent gained of the property which you're viewing.
#
# COMMAND_NAMES = ["Buy", "Upgrade", "Rent Out", "Cancel Rent", "Sell"]
# The vocabs for what you can do with a property.
#
# USE_MENU_COMMAND = key
# Set to false if you want to entirely disable the menu command for properties.
#
# CONDITIONS_FOR_MENU = [SEE CONDITION VALUES AT THE END OF THE INSTRUCTIONS]
# Conditions for the menu command to appear.
#
# PROPERTIES_NAME = "name"
# Name of the properties option in the menu.
#
# BUY_SOUND = ["type", "file_name", volume, pitch]
# Sound played when buying a property. Set type to SE if it's an se, to ME if it's
# an me. Note that this script if case sensitive when it comes to the types.
# If you don't want a sound to play, set "file_name" to nil.
#
# UPGRADE_SOUND
# Same as above.
#
# RENT_SOUND
# Same as above.
#
# CANCEL_RENT_SOUND
# Same as above.
#
# SELL_SOUND
# Same as above.
#
# NO_CHANGE_ON_SELL = key
# If key is true, upgrades are NOT removed when selling properties. If you want
# the player to be able to change this, use a script call and simply enter
# EME::PROPERTY::NO_CHANGE_ON_SELL = true/false.
# WARNING. Don't do ^ that mid-game. It has a slight effect on the prices.
# However this only applies if...
#
# MONEY_FOR_UPGRADES = [key, "formula"]
# ... the key of this constant is true.
# Set formula to the formula of the addition to the sell price. You can use
# script calls, current_upgrade (if no upgrades, this is 0), and
# upgrade_price (price as defined in the begin of the game).
#
#
# ----------------
# CONDITION VALUES
# ----------------
# Conditions can have as many of the following conditions as you want:
# standard syntax =
# [[condition, values for condition], [condition, values for condition]]
#
# ["I", item_id]
# "I" indicates that item with item_id is required.
#
# ["A", armor_id, include_equip]
# "A" indicates that armor with armor_id is required. If include_equip is true,
# armor of the actors will also be checked.
#
# ["W", weapon_id, include_equip]
# Same as "A", but for weapons.
#
# ["S", switch_id, key]
# "S" indicates that switch with switch_id should have the value of key.
#
# ["V", variable_id, required_value, "condition"]
# "V" indicates that variable with variable_id should apply to "condition"
# "condition" can be:
# "="
# value of the variable should be equal to required_value.
# "<"
# value of the variable should be less than required_value.
# "<="
# value of the variable should be less than or equal to required_value.
# ">"
# value of the variable should be more than required_value.
# ">="
# value of the variable should be more than or equal to required_value.
# "!"
# value of the variable should be the complement of (everything but)
# required_value.
#
# ["Ac", actor_id, include?]
# "Ac" indicates that actor with actor_id should be in the party if include? is
# true, or not in the party if include? is false.
#
#
# Have fun with the script!
#----------------------------------------------------------------------------
# Made as request for:
# ShadowFox
#----------------------------------------------------------------------------
# If you have any issues with this script, contact me at
# http://www.rpgmakervxace.net/index.php?/
#============================================================================
#
# CONFIGURATION
#
#============================================================================
module EME
  module PROPERTY

	Properties = {

	1 => [
		  ["La Belle Maison", "property1.png", 5000, 1000, 0, 0],
		  [500, 1000, 1000, 50, 100, 250],
		  [50, 120, 175, 240, 10, 40, 80, 150],
		  [],
		  [],
		  [],
		  []
		  ],

	2 => [
		  ["Epic Villa", "property2.png", 2000, 5000, 0, 0],
		  [240, 450, 780, 300, 500, 1000],
		  [25, 125, 625, 1000, 5, 50, 200, 500],
		  [],
		  [["I", 15]],
		  [],
		  []
		  ]

	}

	# note, rent should always be 1 more than upgrades

	RANDOMIZE_PRICES = [true, true, true, true]
	PERCENTAGE_MODS = [false, false, false, false]
	FORMULA_SELL_PRICE = [true, "buy_price * 0.75", 0]
	VARIABLE = 5001
	OWNED_ICON = 238
	CANNOT_MANAGE_COLOR = 8
	IMAGE_FOLDER = "Graphics/Properties/"
	STATE_RENTED_OUT = "Rented Out"
	STATE_OWNED = "Owned"
	STATE_BUYABLE = "Buyable"
	RENT_GAINED = "Rent Gained"
	COMMANDS_NAMES = ["Buy", "Upgrade", "Rent Out", "Cancel Rent", "Sell"]
	USE_MENU_COMMAND = true
	CONDITIONS_FOR_MENU = []
	PROPERTIES_NAME = "Properties"
	BUY_SOUND = ["SE", "Shop", 80, 100]
	UPGRADE_SOUND = ["ME", "Item", 80, 130]
	RENT_SOUND = ["SE", "Coin", 80, 85]
	CANCEL_RENT_SOUND = ["SE", "Coin", 80, 65]
	SELL_SOUND = ["SE", "Shop", 80, 100]
	NO_CHANGE_ON_SELL = true # upgrades stay if the property is sold
	MONEY_FOR_UPGRADES = [true, "upgrade_price * 0.60"] # sell price receives a bonus for every upgrade, along with formula

  end
end

#---------------------------------------------------------
# Only edit things past here if you know what you're doing
#---------------------------------------------------------
#============================================================================
#
# DataManager
# Initializes and saves/loads the required variables.
#============================================================================
module DataManager

  class << self
	alias eme_prop_create_objects create_game_objects
	alias eme_prop_make_contents make_save_contents
	alias eme_prop_extract_contents extract_save_contents
  end

  def self.create_game_objects
	self.eme_prop_create_objects
	$property_variables = Property_Variables.new
  end

  def self.make_save_contents
	contents = self.eme_prop_make_contents
	contents[:eme_properties] = $property_variables
	return contents
  end

  def self.extract_save_contents(contents)
	self.eme_prop_extract_contents(contents)
	$property_variables = contents[:eme_properties]
  end

end

#============================================================================
#
# Property_Variables
# Class which initializes all variables of the properties.
#============================================================================

class Property_Variables

  def initialize
	@data_properties = Array.new
	@data_upgrades   = Array.new
	@data_rent	   = Array.new
	create_property_values
	create_upgrade_values
	create_rent_values
  end

  def create_property_values
	config_var = EME::PROPERTY::Properties
	for i in 1..config_var.size
	  @data_properties[i - 1] = []
	  @data_properties[i - 1][0] = config_var[i][0][0]
	  @data_properties[i - 1][1] = config_var[i][0][1]
	  if EME::PROPERTY::RANDOMIZE_PRICES[0]
		@data_properties[i - 1][2] = [[config_var[i][0][2] * (1 + rand(config_var[i][0][3]) / 100)].min, 0].max if EME::PROPERTY::PERCENTAGE_MODS[0]
		@data_properties[i - 1][2] = config_var[i][0][2] + rand(config_var[i][0][3]) unless EME::PROPERTY::PERCENTAGE_MODS[0]
	  else
		@data_properties[i - 1][2] = config_var[i][0][2]
	  end
	  unless EME::PROPERTY::FORMULA_SELL_PRICE[0]
		if EME::PROPERTY::RANDOMIZE_PRICES[1]
		  @data_properties[i - 1][3] = [[config_var[i][0][4] * (1 + rand(config_var[i][0][5]) / 100)].min, 0].max if EME::PROPERTY::PERCENTAGE_MODS[1]
		  @data_properties[i - 1][3] = config_var[i][0][4] + rand(config_var[i][0][5]) unless EME::PROPERTY::PERCENTAGE_MODS[1]
		else
		  @data_properties[i - 1][3] = config_var[i][0][4]
		end
	  else
		buy_price = @data_properties[i - 1][2]
		standard_buy_price = config_var[i][0][2]
		standard_buy_mod = config_var[i][0][3]
		standard_sell_price = config_var[i][0][4]
		standard_sell_mod = config_var[i][0][5]
		upgrades = 0 + EME::PROPERTY::FORMULA_SELL_PRICE[2]
		rent = 0
		formula = EME::PROPERTY::FORMULA_SELL_PRICE[1]
		@data_properties[i - 1][3] = [Kernel.eval(formula).to_i, 0].max if formula != nil
		@data_properties[i - 1][3] = config_var[i][0][4] unless formula != nil
	  end
	  @data_properties[i - 1][4] = 0
	  @data_properties[i - 1][5] = false
	  @data_properties[i - 1][6] = false
	  @data_properties[i - 1][7] = 0
	  @data_properties[i - 1][8] = config_var[i][3]
	  @data_properties[i - 1][9] = config_var[i][4]
	  @data_properties[i - 1][10]= config_var[i][5]
	  @data_properties[i - 1][11]= config_var[i][6]
	end
  end

  def create_upgrade_values
	config_var = EME::PROPERTY::Properties
	for i in 1..config_var.size
	  @data_upgrades[i - 1] = []
	  if EME::PROPERTY::RANDOMIZE_PRICES[2]
		max_element = config_var[i][1].size / 2
		for j in 0...max_element
		  value = config_var[i][1][j]
		  value *= [[1 + (rand(config_var[i][1][j + max_element]) / 100)].min, 0].max if EME::PROPERTY::PERCENTAGE_MODS[2]
		  value += rand(config_var[i][1][j + max_element]) unless EME::PROPERTY::PERCENTAGE_MODS[2]
		  @data_upgrades[i - 1][j] = value
		end
	  else
		for j in 0...config_var[i][1].size
		  @data_upgrades[i - 1][j] = config_var[i][1][j]
		end
	  end
	end
  end

  def create_rent_values
	config_var = EME::PROPERTY::Properties
	for i in 1..config_var.size
	  @data_rent[i - 1] = []
	  if EME::PROPERTY::RANDOMIZE_PRICES[3]
		max_element = config_var[i][2].size / 2
		for j in 0...max_element
		  value = config_var[i][2][j]
		  value *= [[1 + (rand(config_var[i][2][j + max_element]) / 100)].min, 0].max if EME::PROPERTY::PERCENTAGE_MODS[3]
		  value += rand(config_var[i][2][j + max_element]) unless EME::PROPERTY::PERCENTAGE_MODS[3]
		  @data_rent[i - 1][j] = value
		end
	  else
		for j in 0...config_var[i][2].size
		  @data_rent[i - 1][j] = config_var[i][2][j]
		end
	  end
	end
  end

  def get_rent(property)
	property and @data_properties[property][5] and @data_properties[property][6] ? $game_party.gain_gold(get_info("rent", property, upgrades(property))) : return
  end

  def get_rent_all
	$game_variables[EME::PROPERTY::VARIABLE] = 0 if EME::PROPERTY::VARIABLE != nil
	valid_properties = @data_properties.select {|property| property[5] and property[6]}
	return if valid_properties == nil
	for i in 0...valid_properties.size
	  id = index(valid_properties[i])
	  $game_party.gain_gold(get_info("rent", id, upgrades(id)))
	  $game_variables[EME::PROPERTY::VARIABLE] += get_info("rent", id, upgrades(id)) if EME::PROPERTY::VARIABLE != nil
	end
  end

  def get_info(type, property, parameter)
	case type
	when "property"
	  return @data_properties[property][parameter] if property != nil and parameter != nil
	when "upgrades"
	  fail = -1
	  if EME::PROPERTY::RANDOMIZE_PRICES[2]
		max_element = EME::PROPERTY::Properties[property + 1][1].size / 2
		@data_properties[property][4] == max_element ? fail : @data_upgrades[property][parameter]
	  else
		max_element = EME::PROPERTY::Properties[property + 1][1].size
		@data_properties[property][4] == max_element ? fail : @data_upgrades[property][parameter]
	  end
	when "rent"
	  return @data_rent[property][parameter]
	end
  end

  def upgrades(property)
	return get_info("property", property, 4)
  end

  def owned?(property)
	return get_info("property", property, 5)
  end

  def rented_out?(property)
	return get_info("property", property, 6)
  end

  def max_upgrade?(property)
	get_info("upgrades", property, upgrades(property)) == -1 ? true :  false
  end

  def [](property_id)
	return @data_properties[property_id]
  end

  def properties
	return @data_properties
  end

  def index(property)
	return @data_properties.index(property)
  end

  def undo_vars_and_switches(property)
	key = 10
	upgrade = @data_properties[property_id][key].size - 1
	loop do
	  unless @data_properties[property_id][key][upgrade] == nil
		for i in 0...@data_properties[property_id][key][upgrade].size
		  next if @data_properties[property_id][key][upgrade][i] == nil
		  case @data_properties[property_id][key][upgrade][i][0]
		  when "S"
			$game_switches[@data_properties[property_id][key][upgrade][i][1]] = (!@data_properties[property_id][10][upgrade][i][2])
		  when "V"
			case @data_properties[property_id][key][upgrade][i][1]
			when "+"
			  $game_variables[@data_properties[property_id][key][upgrade][i][2]] -= @data_properties[property_id][10][upgrade][i][3]
			when "-"
			  $game_variables[@data_properties[property_id][key][upgrade][i][2]] += @data_properties[property_id][10][upgrade][i][3]
			when "*"
			  $game_variables[@data_properties[property_id][key][upgrade][i][2]] /= @data_properties[property_id][10][upgrade][i][3]
			when "/"
			  $game_variables[@data_properties[property_id][key][upgrade][i][2]] *= @data_properties[property_id][10][upgrade][i][3]
			end
		  when "SS"
			$game_self_switches[@data_properties[property_id][key][upgrade][i][1]] = (!@data_properties[property_id][10][upgrade][i][2])
		  end
		end
	  end
	  upgrade -= 1
	  break if upgrade == -1
	end
  end

  def rev_change_vars_and_switches(property, rent = false)
	upgrade = upgrades(property_id)
	rent ? key = 11 : key = 10
	return if @data_properties[property_id][key][upgrade] == nil
	for i in 0...@data_properties[property_id][key][upgrade].size
	  next if @data_properties[property_id][key][upgrade][i] == nil
	  case @data_properties[property_id][key][upgrade][i][0]
	  when "S"
		$game_switches[@data_properties[property_id][key][upgrade][i][1]] = (!@data_properties[property_id][10][upgrade][i][2])
	  when "V"
		case @data_properties[property_id][key][upgrade][i][1]
		when "+"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] -= @data_properties[property_id][10][upgrade][i][3]
		when "-"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] += @data_properties[property_id][10][upgrade][i][3]
		when "*"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] /= @data_properties[property_id][10][upgrade][i][3]
		when "/"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] *= @data_properties[property_id][10][upgrade][i][3]
		end
	  when "SS"
		$game_self_switches[@data_properties[property_id][key][upgrade][i][1]] = (!@data_properties[property_id][10][upgrade][i][2])
	  end
	end
  end

  def change_vars_and_switches(property_id, rent = false)
	upgrade = upgrades(property_id)
	rent ? key = 11 : key = 10
	return if @data_properties[property_id][key][upgrade] == nil
	for i in 0...@data_properties[property_id][key][upgrade].size
	  next if @data_properties[property_id][key][upgrade][i] == nil
	  case @data_properties[property_id][key][upgrade][i][0]
	  when "S"
		$game_switches[@data_properties[property_id][key][upgrade][i][1]] = @data_properties[property_id][10][upgrade][i][2]
	  when "V"
		case @data_properties[property_id][key][upgrade][i][1]
		when "="
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] = @data_properties[property_id][10][upgrade][i][3]
		when "+"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] += @data_properties[property_id][10][upgrade][i][3]
		when "-"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] -= @data_properties[property_id][10][upgrade][i][3]
		when "*"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] *= @data_properties[property_id][10][upgrade][i][3]
		when "/"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] /= @data_properties[property_id][10][upgrade][i][3]
		when "%"
		  $game_variables[@data_properties[property_id][key][upgrade][i][2]] = $game_variables[@data_properties[property_id][key][upgrade][i][2]] % @data_properties[property_id][10][upgrade][i][3]
		end
	  when "SS"
		$game_self_switches[@data_properties[property_id][key][upgrade][i][1]] = @data_properties[property_id][10][upgrade][i][2]
	  end
	end
  end

end

#============================================================================
#
# Eme_Prop_Properties_List
# Window with the list of properties.
#============================================================================

class Eme_Prop_Properties_List < Window_Selectable

  def initialize(x, y, width, height)
	super
	@data = []
	$eme_prop_last = 0 unless $eme_prop_last != nil
	select_last
  end

  def active=(active)
	super
	call_update_windows
  end

  def index=(index)
	super
	call_update_windows
  end

  def col_max
	return 1
  end

  def item_max
	@data ? @data.size : 1
  end

  def property
	@data && index >= 0 ? @data[index] : nil
  end

  def make_properties_list
	@data = $property_variables.properties.select {|property| show_property?(property)}
  end

  def show_property?(property_array)
	enabled = true
	conditions = property_array[8]
	for x in 0...conditions.size
	  case conditions[x][0]
	  when "I"
		enabled = false unless $data_weapons[conditions[x][1]] != nil and $game_party.has_item?($data_items[conditions[x][1]])
	  when "A"
		enabled = false unless $data_weapons[conditions[x][1]] != nil and $game_party.has_item?($data_armors[conditions[x][1]], conditions[x][2])
	  when "W"
		enabled = false unless $data_weapons[conditions[x][1]] != nil and $game_party.has_item?($data_armors[conditions[x][1]], conditions[x][2])
	  when "S"
		if conditions[x][2]
		  enabled = false unless $game_switches[conditions[x][1]]
		else
		  enabled = false if $game_switches[conditions[x][1]]
		end
	  when "V"
		case conditions[x][3]
		when "="
		  enabled = false unless $game_variables[conditions[x][1]] == conditions[x][2]
		when "<"
		  enabled = false unless $game_variables[conditions[x][1]] < conditions[x][2]
		when ">"
		  enabled = false unless $game_variables[conditions[x][1]] > conditions[x][2]
		when "<="
		  enabled = false unless $game_variables[conditions[x][1]] <= conditions[x][2]
		when ">="
		  enabled = false unless $game_variables[conditions[x][1]] >= conditions[x][2]
		when "!"
		  enabled = false unless $game_variables[conditions[x][1]] != conditions[x][2]
		end
	  when "Ac"
		if conditions[x][2]
		  enabled = false unless $game_party.all_members.include?($game_actors[conditions[x][1]])
		else
		  enabled = false if $game_party.members.include?($game_actors[conditions[x][1]])
		end
	  end
	end
	return enabled
  end

  def select_last
	select(@data.index($eme_prop_last) || 0) if $eme_prop_last != nil
  end

  def draw_item(index)
	property = @data[index]
	if property != nil
	  rect = item_rect(index)
	  rect.width -= 4
	  draw_property_name(property, rect.x, rect.y)
	end
  end

  def property_manage_enabled?(property_array)
	enabled = true
	conditions = property_array[9]
	for x in 0...conditions.size
	  case conditions[x][0]
	  when "I"
		enabled = false unless $data_items[conditions[x][1]] != nil and $game_party.has_item?($data_items[conditions[x][1]])
	  when "A"
		enabled = false unless $data_armors[conditions[x][1]] != nil and $game_party.has_item?($data_armors[conditions[x][1]], conditions[x][2])
	  when "W"
		enabled = false unless $data_weapons[conditions[x][1]] != nil and $game_party.has_item?($data_armors[conditions[x][1]], conditions[x][2])
	  when "S"
		if conditions[x][2]
		  enabled = false unless $game_switches[conditions[x][1]]
		else
		  enabled = false if $game_switches[conditions[x][1]]
		end
	  when "V"
		case conditions[x][3]
		when "="
		  enabled = false unless $game_variables[conditions[x][1]] == conditions[x][2]
		when "<"
		  enabled = false unless $game_variables[conditions[x][1]] < conditions[x][2]
		when ">"
		  enabled = false unless $game_variables[conditions[x][1]] > conditions[x][2]
		when "<="
		  enabled = false unless $game_variables[conditions[x][1]] <= conditions[x][2]
		when ">="
		  enabled = false unless $game_variables[conditions[x][1]] >= conditions[x][2]
		when "!"
		  enabled = false unless $game_variables[conditions[x][1]] != conditions[x][2]
		end
	  when "Ac"
		if conditions[x][2]
		  enabled = false unless $game_party.members.include?($game_actors[conditions[x][1]])
		else
		  enabled = false if $game_party.members.include?($game_actors[conditions[x][1]])
		end
	  end
	end
	return enabled
  end

  def draw_property_name(property, x, y, width = 172)
	return unless property != nil
	draw_icon(EME::PROPERTY::OWNED_ICON, x, y, true) if EME::PROPERTY::OWNED_ICON and $property_variables.owned?($property_variables.index(property))
	if property_manage_enabled?(property)
	  change_color(normal_color)
	else
	  change_color(text_color(EME::PROPERTY::CANNOT_MANAGE_COLOR))
	end
	draw_text(x + 24, y, width - 54, line_height, property[0])
	change_color(system_color)
	draw_text(x, y, width, line_height, "(" + property[4].to_s + ")", 2)
  end

  def refresh
	make_properties_list
	create_contents
	draw_all_items
	call_update_windows
  end

  def name_window=(name_window)
	@name_window = name_window
	@name_window.set_property(property)
  end

  def picture_window=(picture_window)
	@picture_window = picture_window
	@picture_window.set_property(property)
  end

  def info_window=(info_window)
	@info_window = info_window
	@info_window.set_property(property)
  end

  def commands_window=(commands_window)
	@commands_window = commands_window
	@commands_window.set_property(property)
  end

  def update_windows
	@name_window.set_property(property) if @name_window
	@picture_window.set_property(property) if @picture_window
	@info_window.set_property(property) if @info_window
	@commands_window.set_property(property) if @commands_window
  end

  def call_update_windows
	update_windows
  end

end

#============================================================================
#
# Window_Eme_Prop_Name
# Window with the name of the current property.
#============================================================================

class Window_Eme_Prop_Name < Window_Base

  def initialize(x, y, width, height)
	super
	$eme_prop_last != nil ? @property = $eme_prop_last : @property = $property_variables[0]
  end

  def refresh
	contents.clear
	@property != nil ? draw_text(0, 0, contents.width, line_height, @property[0], 1) : draw_text(0, 0, contents.width, line_height, "")
  end

  def set_property(property)
	@property == property ? return : @property = property
	refresh
  end

end

#============================================================================
#
# Window_Eme_Prop_Picture
# Window with picture of the current property.
#============================================================================

class Window_Eme_Prop_Picture < Window_Base

  def initialize(x, y, width, height)
	super
	$eme_prop_last != nil ? @property = $eme_prop_last : @property = $property_variables[0]
  end

  def refresh
	contents.clear
	if @property != nil and @property[1] != nil
	  bitmap = Cache.load_bitmap(EME::PROPERTY::IMAGE_FOLDER, @property[1])
	  rect = Rect.new(0, 0, bitmap.width, bitmap.height)
	  contents.blt(87 - bitmap.width / 2, 87 - bitmap.height / 2, bitmap, rect, $property_variables.owned?($property_variables.index(@property)) ? 255 : translucent_alpha)
	end
  end

  def set_property(property)
	@property == property ? return : @property = property
	refresh
  end

end

#============================================================================
#
# Window_Eme_Prop_Info
# Window which diplays most info about the property.
#============================================================================

class Window_Eme_Prop_Info < Window_Base

  def initialize(x, y, width, height)
	super
	$eme_prop_last != nil ? @property = $eme_prop_last : @property = $property_variables[0]
  end

  def refresh
	contents.clear
	id = $property_variables.index(@property)
	change_color(system_color)
	@property != nil and $property_variables.owned?(id) ? draw_text(0, 0, contents.width, line_height, "To Upgrade:") : draw_text(0, 0, contents.width, line_height, "Price:")
	change_color(normal_color)
	if @property != nil and $property_variables.owned?(id)
	  draw_text(0, 24, contents.width, line_height, $property_variables.get_info("upgrades", id, $property_variables.upgrades(id)).to_s) unless $property_variables.max_upgrade?(id)
	  draw_text(0, 24, contents.width, line_height, "-----") if $property_variables.max_upgrade?(id)
	elsif @property != nil
	  draw_text(0, 24, contents.width, line_height, @property[2].to_s)
	else
	  draw_text(0, 24, contents.width, line_height, "")
	end
	change_color(system_color)
	@property != nil and $property_variables.owned?(id) ? draw_text(0, 48, contents.width, line_height, "Sell Price:") : draw_text(0, 48, contents.width, line_height, "")
	change_color(normal_color)
	@property != nil and $property_variables.owned?(id) ? draw_text(0, 72, contents.width, line_height, @property[3].to_s) : draw_text(0, 72, contents.width, line_height, "")
	change_color(system_color)
	draw_text(0, 96, contents.width, line_height, "State:")
	change_color(normal_color)
	if @property !=
	  if $property_variables.rented_out?(id)
		draw_text(0, 120, contents.width, line_height, EME::PROPERTY::STATE_RENTED_OUT)
	  elsif $property_variables.owned?(id)
		draw_text(0, 120, contents.width, line_height, EME::PROPERTY::STATE_OWNED)
	  else
		draw_text(0, 120, contents.width, line_height, EME::PROPERTY::STATE_BUYABLE)
	  end
	else
	  draw_text(0, 120, contents.width, line_height, "")
	end
	change_color(system_color)
	@property != nil and $property_variables.rented_out?(id) ? draw_text(0, 144, contents.width, line_height, EME::PROPERTY::RENT_GAINED + ":") : draw_text(0, 144, contents.width, line_height, "")
	change_color(normal_color)
	@property != nil and $property_variables.rented_out?(id) ? draw_text(0, 168, contents.width, line_height, $property_variables.get_info("rent", id, $property_variables.upgrades(id))) : draw_text(0, 168, contents.width, line_height, "")
  end

  def set_property(property)
	@property == property ? return : @property = property
	refresh
  end

end

#============================================================================
#
# Eme_Property_Window_Gold
# Same as Window_Gold, but with customizable x, y, width and height.
#============================================================================

class Eme_Property_Window_Gold < Window_Base

  def initialize(x, y, width, height)
	super
	refresh
  end

  def refresh
	contents.clear
	draw_currency_value(value, currency_unit, 4, 0, contents.width - 8)
  end

  def value
	$game_party.gold
  end

  def currency_unit
	Vocab::currency_unit
  end

  def open
	refresh
	super
  end
end

#============================================================================
#
# Window_Eme_Prop_Commands
# Window with the options for the property.
#============================================================================

class Window_Eme_Prop_Commands < Window_HorzCommand

  def initialize(x, y)
	$eme_prop_last != nil ? @property = $eme_prop_last : @property = $property_variables[0]
	super
  end

  def col_max
	if @property != nil and $property_variables.owned?($property_variables.index(@property))
	  return 3
	else
	  return 1
	end
  end

  def window_width
	return 198 + 148
  end

  def window_height
	return 48
  end

  def property
	return @property
  end

  def make_command_list
	if @property != nil and $property_variables.owned?($property_variables.index(@property))
	  add_command(EME::PROPERTY::COMMANDS_NAMES[1], :upgrade, upgrade_enabled)
	  add_command(EME::PROPERTY::COMMANDS_NAMES[2], :rent, property_enabled) unless $property_variables.rented_out?($property_variables.index(@property))
	  add_command(EME::PROPERTY::COMMANDS_NAMES[3], :cancel_rent, property_enabled) if $property_variables.rented_out?($property_variables.index(@property))
	  add_command(EME::PROPERTY::COMMANDS_NAMES[4], :sell, property_enabled)
	else
	  add_command(EME::PROPERTY::COMMANDS_NAMES[0], :buy, buy_enabled)
	end
  end

  def property_enabled
	if @property != nil
	  enabled = true
	  conditions = @property[9]
	  for x in 0...conditions.size
		case conditions[x][0]
		when "I"
		  enabled = false unless $data_items[conditions[x][1]] != nil and $game_party.has_item?($data_items[conditions[x][1]])
		when "A"
		enabled = false unless $data_armors[conditions[x][1]] != nil and $game_party.has_item?($data_armors[conditions[x][1]], conditions[x][2])
		when "W"
		  enabled = false unless $data_weapons[conditions[x][1]] != nil and $game_party.has_item?($data_armors[conditions[x][1]], conditions[x][2])
		when "S"
		  if conditions[x][2]
			enabled = false unless $game_switches[conditions[x][1]]
		  else
			enabled = false if $game_switches[conditions[x][1]]
		  end
		when "V"
		  case conditions[x][3]
		  when "="
			enabled = false unless $game_variables[conditions[x][1]] == conditions[x][2]
		  when "<"
			enabled = false unless $game_variables[conditions[x][1]] < conditions[x][2]
		  when ">"
			enabled = false unless $game_variables[conditions[x][1]] > conditions[x][2]
		  when "<="
			enabled = false unless $game_variables[conditions[x][1]] <= conditions[x][2]
		  when ">="
			enabled = false unless $game_variables[conditions[x][1]] >= conditions[x][2]
		  when "!"
			enabled = false unless $game_variables[conditions[x][1]] != conditions[x][2]
		  end
		when "Ac"
		  if conditions[x][2]
			enabled = false unless $game_party.members.include?($game_actors[conditions[x][1]])
		  else
			enabled = false if $game_party.members.include?($game_actors[conditions[x][1]])
		  end
		end
	  end
	  return enabled
	else
	  return false
	end
  end

  def buy_enabled
	return false unless property_enabled
	@property != nil and $game_party.gold >= @property[2] ? true : false
  end

  def upgrade_enabled
	return false unless property_enabled
	@property != nil and !$property_variables.max_upgrade?($property_variables.index(@property)) and $game_party.gold >= $property_variables.get_info("upgrades", $property_variables.index(@property), $property_variables.upgrades($property_variables.index(@property))) ? true : false
  end

  def set_property(property)
	@property == property ? return : @property = property
	clear_command_list
	make_command_list
	refresh
  end

end

#============================================================================
#
# Window_MenuCommand
# Adds the property menu command.
#============================================================================

class Window_MenuCommand

  alias eme_prop_original_commands add_original_commands
  def add_original_commands
	eme_prop_original_commands
	add_command(EME::PROPERTY::PROPERTIES_NAME, :properties, properties_enable?) if EME::PROPERTY::USE_MENU_COMMAND
  end

  def properties_enable?
	enabled = true
	for x in 0...EME::PROPERTY::CONDITIONS_FOR_MENU.size
	  case EME::PROPERTY::CONDITIONS_FOR_MENU[x][0]
	  when "I"
		enabled = false unless $data_items[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] != nil and $game_party.has_item?($data_items[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]])
	  when "A"
		enabled = false unless $data_armors[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] != nil and $game_party.has_item?($data_armors[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]], EME::PROPERTY::CONDITIONS_FOR_MENU[x][2])
	  when "W"
		enabled = false unless $data_weapons[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] != nil and $game_party.has_item?($data_armors[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]], EME::PROPERTY::CONDITIONS_FOR_MENU[x][2])
	  when "S"
		if EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		  enabled = false unless $game_switches[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]]
		else
		  enabled = false if $game_switches[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]]
		end
	  when "V"
		case EME::PROPERTY::CONDITIONS_FOR_MENU[x][3]
		when "="
		  enabled = false unless $game_variables[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] == EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		when "<"
		  enabled = false unless $game_variables[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] < EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		when ">"
		  enabled = false unless $game_variables[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] > EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		when "<="
		  enabled = false unless $game_variables[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] <= EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		when ">="
		  enabled = false unless $game_variables[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] >= EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		when "!"
		  enabled = false unless $game_variables[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]] != EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		end
	  when "Ac"
		if EME::PROPERTY::CONDITIONS_FOR_MENU[x][2]
		  enabled = false unless $game_party.members.include?($game_actors[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]])
		else
		  enabled = false if $game_party.members.include?($game_actors[EME::PROPERTY::CONDITIONS_FOR_MENU[x][1]])
		end
	  end
	end
	return enabled
  end

end

#============================================================================
#
# Scene_Menu
# Adds the handler to access the property scene from the menu.
#============================================================================

class Scene_Menu

  alias eme_prop_create_command_window create_command_window
  def create_command_window
	eme_prop_create_command_window
	@command_window.set_handler(:properties, method(:properties_scene)) if EME::PROPERTY::USE_MENU_COMMAND
  end

  def properties_scene
	SceneManager.call(Scene_Eme_Prop_Property)
  end

end
#============================================================================
#
# Scene_Eme_Prop_Property
# Scene where everything takes places.
#============================================================================

class Scene_Eme_Prop_Property < Scene_Base

  def start
	super
	create_background
	create_properties_list
	create_property_name_window
	create_property_picture_window
	create_property_info_window
	create_gold_window
	create_command_window
	refresh_all
	@prop_list.activate
	@command_window.deactivate
  end

  def create_background
	@background_sprite = Sprite.new
	@background_sprite.bitmap = SceneManager.background_bitmap
	@background_sprite.color.set(16, 16, 16, 128)
  end

  def create_properties_list
	@prop_list = Eme_Prop_Properties_List.new(0, 0, 198, Graphics.height)
	@prop_list.viewport = @viewport
	@prop_list.set_handler(:ok, method(:on_prop_list_ok))
	@prop_list.set_handler(:cancel, method(:return_scene))
  end

  def create_property_name_window
	@name_window = Window_Eme_Prop_Name.new(198, 0, Graphics.width - 198, 48)
	@name_window.viewport = @viewport
	@prop_list.name_window = @name_window
  end

  def create_property_picture_window
	@picture_window = Window_Eme_Prop_Picture.new(198, 48, 198, 198)
	@picture_window.viewport = @viewport
	@prop_list.picture_window = @picture_window
  end

  def create_property_info_window
	@info_window = Window_Eme_Prop_Info.new(396, 48, 148, 198 + 96)
	@info_window.viewport = @viewport
	@prop_list.info_window = @info_window
  end

  def create_gold_window
	@gold_window = Eme_Property_Window_Gold.new(198, 198 + 48, 198, 48)
	@gold_window.viewport = @viewport
  end

  def create_command_window
	@command_window = Window_Eme_Prop_Commands.new(198, @info_window.height + 48)
	@command_window.viewport = @viewport
	@command_window.set_handler(:buy, method(:buy_property))
	@command_window.set_handler(:upgrade, method(:upgrade_property))
	@command_window.set_handler(:rent, method(:rent_property))
	@command_window.set_handler(:cancel_rent, method(:cancel_rent_property))
	@command_window.set_handler(:sell, method(:sell_property))
	@command_window.set_handler(:cancel, method(:back_to_list))
	@prop_list.commands_window = @command_window
  end

  def on_prop_list_ok
	$eme_prop_last = @prop_list.property
	@command_window.select(0)
	@command_window.activate
  end

  def back_to_list
	@command_window.deactivate
	@prop_list.activate
  end

  def buy_property
	id = $property_variables.index(@command_window.property)
	$game_party.lose_gold($property_variables[id][2])
	$property_variables[id][5] = true
	change_vars_and_switches(id)
	case EME::PROPERTY::BUY_SOUND[0]
	when "ME"
	  Audio.me_play('Audio/ME/' + EME::PROPERTY::BUY_SOUND[1], EME::PROPERTY::BUY_SOUND[2], EME::PROPERTY::BUY_SOUND[3]) if EME::PROPERTY::BUY_SOUND[1] != nil
	when "SE"
	  Audio.se_play('Audio/SE/' + EME::PROPERTY::BUY_SOUND[1], EME::PROPERTY::BUY_SOUND[2], EME::PROPERTY::BUY_SOUND[3]) if EME::PROPERTY::BUY_SOUND[1] != nil
	end
	refresh_all
	@command_window.activate
  end

  def upgrade_property
	id = $property_variables.index(@command_window.property)
	current_upgrade = $property_variables.upgrades(id)
	upgrade_price = $property_variables.get_info("upgrades", id, current_upgrade)
	$game_party.lose_gold(upgrade_price)
	$property_variables[id][4] += 1
	$property_variables[id][7] += [Kernel.eval(EME::PROPERTY::MONEY_FOR_UPGRADES[1]).to_i, 0].max if EME::PROPERTY::MONEY_FOR_UPGRADES[0] and EME::PROPERTY::MONEY_FOR_UPGRADES[1] != nil #[Kernel.eval(EME::PROPERTY::MONEY_FOR_UPGRADES[1]).to_i, 0].max if EME::PROPERTY::MONEY_FOR_UPGRADES[0] and EME::PROPERTY::MONEY_FOR_UPGRADES[1] != nil
	change_vars_and_switches(id)
	case EME::PROPERTY::UPGRADE_SOUND[0]
	when "ME"
	  Audio.me_play('Audio/ME/' + EME::PROPERTY::UPGRADE_SOUND[1], EME::PROPERTY::UPGRADE_SOUND[2], EME::PROPERTY::UPGRADE_SOUND[3]) if EME::PROPERTY::UPGRADE_SOUND[1] != nil
	when "SE"
	  Audio.se_play('Audio/SE/' + EME::PROPERTY::UPGRADE_SOUND[1], EME::PROPERTY::UPGRADE_SOUND[2], EME::PROPERTY::UPGRADE_SOUND[3]) if EME::PROPERTY::UPGRADE_SOUND[1] != nil
	end
	refresh_all
	@command_window.activate
  end

  def rent_property
	id = $property_variables.index(@command_window.property)
	$property_variables[id][6] = true
	change_vars_and_switches(id, false, true)
	case EME::PROPERTY::RENT_SOUND[0]
	when "ME"
	  Audio.me_play('Audio/ME/' + EME::PROPERTY::RENT_SOUND[1], EME::PROPERTY::RENT_SOUND[2], EME::PROPERTY::RENT_SOUND[3]) if EME::PROPERTY::RENT_SOUND[1] != nil
	when "SE"
	  Audio.se_play('Audio/SE/' + EME::PROPERTY::RENT_SOUND[1], EME::PROPERTY::RENT_SOUND[2], EME::PROPERTY::RENT_SOUND[3]) if EME::PROPERTY::RENT_SOUND[1] != nil
	end
	refresh_all
	@command_window.activate
  end

  def cancel_rent_property
	id = $property_variables.index(@command_window.property)
	$property_variables[id][6] = false
	change_vars_and_switches(id, true, true)
	case EME::PROPERTY::CANCEL_RENT_SOUND[0]
	when "ME"
	  Audio.me_play('Audio/ME/' + EME::PROPERTY::CANCEL_RENT_SOUND[1], EME::PROPERTY::RENT_SOUND[2], EME::PROPERTY::CANCEL_RENT_SOUND[3]) if EME::PROPERTY::CANCEL_RENT_SOUND[1] != nil
	when "SE"
	  Audio.se_play('Audio/SE/' + EME::PROPERTY::CANCEL_RENT_SOUND[1], EME::PROPERTY::RENT_SOUND[2], EME::PROPERTY::CANCEL_RENT_SOUND[3]) if EME::PROPERTY::CANCEL_RENT_SOUND[1] != nil
	end
	refresh_all
	@command_window.activate
  end

  def sell_property
	id = $property_variables.index(@command_window.property)
	sell_price = $property_variables[id][3] + $property_variables[id][7]
	$game_party.gain_gold(sell_price)
	unless EME::PROPERTY::NO_CHANGE_ON_SELL
	  $property_variables[id][4] = 0
	  $property_variables[id][7] = 0
	  $property_variables.undo_vars_and_switches(id)
	end
	$property_variables[id][5] = false
	$property_variables[id][6] = false
	case EME::PROPERTY::SELL_SOUND[0]
	when "ME"
	  Audio.me_play('Audio/ME/' + EME::PROPERTY::SELL_SOUND[1], EME::PROPERTY::SELL_SOUND[2], EME::PROPERTY::SELL_SOUND[3]) if EME::PROPERTY::SELL_SOUND[1] != nil
	when "SE"
	  Audio.se_play('Audio/SE/' + EME::PROPERTY::SELL_SOUND[1], EME::PROPERTY::SELL_SOUND[2], EME::PROPERTY::SELL_SOUND[3]) if EME::PROPERTY::SELL_SOUND[1] != nil
	end
	refresh_all
	@command_window.select(0)
	@command_window.activate
  end

  def refresh_all
	@prop_list.refresh
	@prop_list.update_windows
	@name_window.refresh
	@picture_window.refresh
	@info_window.refresh
	@command_window.refresh
	@command_window.select(0)
	@gold_window.refresh
  end

  def change_vars_and_switches(property, reverse = false, rent = false)
	reverse ? $property_variables.rev_change_vars_and_switches(property, rent) : $property_variables.change_vars_and_switches(property, rent)
  end

end