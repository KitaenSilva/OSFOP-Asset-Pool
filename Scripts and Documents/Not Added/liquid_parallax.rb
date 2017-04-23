#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ■ DMO - LIQUID & PARALLAX SCRIPT
#   ● Version:  1.2
#   ● Author:   DasMoony
#   ● Date:	 January 4th, 2012
#   ● Credits:  DasMoony
#   ● LastEdit: February 25th, 2012
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ■ Features (or 8 reasons why to use this one):
#   ● Every single ParallaxLayer can be animated
#   ● Easy-To-Use: Plug&Play
#   ● High compatibility
#   ● Underwater Layer: Put stuff under the water-level
#   ● Water Layer:  Well, it's actually the water itself
#   ● Basic Layer:  Standard Parallax Layer
#   ● Top-Layer:  Use this one for Roofs, etc.
#   ● Choose a global animation pattern (1-2-3 or 1-2-3-2)
#
#==============================================================================
# ■ Description
#   A nice parallax script that makes uses of several layers which you could
#   animate if you want. It's also possible to put events under water, so
#   you're finally able to make fishes and other livings living in the water.
#   But one of the greatest part about all this stuff is how easy you can use
#   it. If you're okay with the default settings you'll never have to touch the
#   script again.
#
#==============================================================================
# ■ Credits and Terms of use
#   ● Credits:
#	 DasMoony
#   ● This script is made for free use in commercial and non-commercial
#	 projects but credits are required
#   ● Do not post direct links to the download file, instead link the page that
#	 contains it
#   ● You're not allowed without the authors permission to distribute this
#	 script. Of course you're allowed to distribute the script within your
#	 project.
#   ● If you're allowed to distribute the script you can't require any rights
#	 about the script
#   ● If this script is used in commercial projects, I demand a free copy of
#	 it. Contact me for the details.
#
#==============================================================================
# ■ Instructions
#   ● Plug the script in
#	 Put this script to the Materials-Section.
#   ● The old Parallaxes
#	 If you want to use any parallaxes in the old way, you can do this without
#	 any problems. Just make sure that they don't have a '['-Character in
#	 their filename
#   ● The Frames
#	 In the following part of the Instructions I often refer to X. X is a
#	 number from 1 to infinite. The numbers describe the order of your frames.
#   ● The Parallaxes
#	   ● Underwater-Layer
#		 This layer represents your underwater-world. Simply add the suffix
#		 [subX] to the filename
#	   ● Water-Layer
#		 This layer represents your water surface. Simply add the suffix
#		 [waterX] to the filename
#	   ● Ground-Layer
#		 This layer represents your actual map. Simply add the suffix
#		 [groundX] to the filename
#	   ● Top-Layer
#		 This layer represents the ceiling, sky, tree crowns or whatever
#		 you have over your heads. Simply add the suffix [topX] to the
#		 filename
#   ● How to use the parallaxes
#	 Name all your parallaxes for a map the same and add one of the suffixes
#	 mentioned above (Example: demomap[ground1].png).
#	 To use your parallax-set simply choose anyone of the set as your
#	 parallax background like ever. That's all.
#   ● Putting stuff underwater
#	 To place an event under the water level change its z-value. You can make
#	 use of 'dmo_change_z(VALUE)' in a script call to place the event itself
#	 in the water or 'dmo_change_z(VALUE,EVENT_ID)' should be lower then
#	 your water-level (-110 by default) and higher then the Underwater-layer
#	 (-250 by default)
#   ● Configurations
#	 You can configure some stuff if you scroll down to the Options (Or search
#	 for OPTIONS)
#	   ● DEFAULT_SPEED
#		 is the speed of the animation. It determines how often a
#		 parallax frame will be changed
#	   ● SUB_Z, WATER_Z and TOP_Z
#		 They are the z-values for the 3 extra-layers
#	   ● PATTERN_LOOP
#		 Define the animation pattern. You can choose between 1-2-3 and
#		 1-2-3-2
#
#==============================================================================
# ■ FAQ
#   ● What if I want to use 3 water frames but only one ground frame?
#	 It's no problem. The script will know how many frames of each type exists
#	 and loops through the ones which are there.
#
#==============================================================================
# ■ Support
#   ● Currently this script is supported on rpgmakervxace.net
#
#==============================================================================
# ■ Technical Aspects (this section is thought for other scripters)
#   ● aliases
#	 ● Spriteset_Map
#	   ● create_parallax
#	   ● dispose_parallax
#	 ● Game_CharacterBase
#	   ● screen_z
#	 ●  Scene_Map
#	   ●  pre_transfer
#   ● overwrites
#	 ● Spriteset_Map
#	   ● update_parallax
#   ● naming standards
#	 I make use of the prefix 'dmo_' for own properties, methods and classes.
#	 For aliases I use the prefix 'dmo_al_'.
#
#==============================================================================
# ■ Contact Information
#   ● Email:
#	 sid.dasmoony@gmail.com
#
#==============================================================================
#==============================================================================

module DMO
#==============================================================================
# ■ OPTIONS - Here you can change some settings.
#==============================================================================
  module OPTIONS
	module PARALLAX
	  # The amount of frames that shall pass by until the update of the
	  # parallax frames
	  # Default value:
	  # 30
	  DEFAULT_SPEED = 30
	  
	  # Z-Indexes of the 3 extra layers
	  # Default values:
	  # SUB_Z = -250
	  # WATER_Z = -110
	  # TOP_Z = 250
	  SUB_Z   = -250
	  WATER_Z = -110
	  TOP_Z   = 250
	  
	  # Defines the animation pattern. If true it's 1-2-3, if false it's
	  # 1-2-3-2
	  PATTERN_LOOP  = false
	end
  end
#==============================================================================
# ■ End of OPTIONS.
#   It's recommended not to change anything behind this point. If you're still
#   do, it's your pretty own risk.
#==============================================================================
end
#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  def dmo_set_parallax_info
	if !@parallax_name.index('[')
	  @dmo_parallax_info = {"ground"=>[[1,1,0],@parallax_name]}
	  return
	end
	name = @parallax_name[0,@parallax_name.index('[')]
	@dmo_parallax_info = {}
	Dir.glob("Graphics/Parallaxes/" + name + '\[*\].png').each do|f|
	  f.gsub(/Graphics\/Parallaxes\/(.*\[(\D*)(\d*)\].png)/){
		@dmo_parallax_info[$2] || @dmo_parallax_info[$2] = Array.new([])
		@dmo_parallax_info[$2][$3.to_i] = $1
		@dmo_parallax_info[$2][0] || @dmo_parallax_info[$2][0] = [1,0,1]
		@dmo_parallax_info[$2][0][1] += 1
		}
	end
  end
  def dmo_add_parallax_layer(type)
	@dmo_parallax_info || dmo_set_parallax_info
	tmp = @dmo_parallax_info[type][@dmo_parallax_info[type][0][0]] if(@dmo_parallax_info[type])
	if tmp
	  @dmo_parallax_info[type][0][0] += @dmo_parallax_info[type][0][2]
	  if DMO::OPTIONS::PARALLAX::PATTERN_LOOP
		@dmo_parallax_info[type][0][0] = 1 if @dmo_parallax_info[type][0][0]>@dmo_parallax_info[type][0][1]
	  else
		@dmo_parallax_info[type][0][2] *= -1 if @dmo_parallax_info[type][0][0] >= @dmo_parallax_info[type][0][1]||@dmo_parallax_info[type][0][0] <= 1
	  end
	end
	return tmp
  end
  alias dmo_al_create_parallax create_parallax
  def create_parallax
	dmo_al_create_parallax
	@dmo_parallax_sub = Plane.new(@viewport1)
	@dmo_parallax_sub.z = -250
	@dmo_parallax_water = Plane.new(@viewport1)
	@dmo_parallax_water.z = -110
	@dmo_parallax_top = Plane.new(@viewport1)
	@dmo_parallax_top.z = 250
	@dmo_counter || @dmo_counter = 0
  end

  def dmo_clear_parallax_cache
	if !@parallax_name.index('[')
	  Cache.parallax(@parallax_name).dispose
	  return
	end
	name = @parallax_name[0,@parallax_name.index('[')]
	Dir.glob("Graphics/Parallaxes/" + name + '\[*\].png').each do|f|
	  f.gsub(/Graphics\/Parallaxes\/(.*\[\D*\d*\].png)/){
		  Cache.parallax($1).dispose}
	end
  end
  alias dmo_al_dispose_parallax dispose_parallax
  def dispose_parallax
	dmo_al_dispose_parallax
	dmo_clear_parallax_cache
	@dmo_parallax_sub.dispose
	@dmo_parallax_water.dispose
	@dmo_parallax_top.dispose
  end
  def update_parallax
	if @parallax_name != $game_map.parallax_name || @dmo_counter >= DMO::OPTIONS::PARALLAX::DEFAULT_SPEED
	  @dmo_parallax_info = nil if @parallax_name != $game_map.parallax_name
	  @dmo_counter < DMO::OPTIONS::PARALLAX::DEFAULT_SPEED || @dmo_counter = 0
	  @parallax_name = $game_map.parallax_name
	  @parallax.bitmap = Cache.parallax(@dmo_tmp) if (@dmo_tmp = dmo_add_parallax_layer("ground"))
	  @dmo_parallax_sub.bitmap = Cache.parallax(@dmo_tmp) if (@dmo_tmp = dmo_add_parallax_layer("sub"))
	  @dmo_parallax_water.bitmap = Cache.parallax(@dmo_tmp) if (@dmo_tmp = dmo_add_parallax_layer("water"))
	  @dmo_parallax_top.bitmap = Cache.parallax(@dmo_tmp) if (@dmo_tmp = dmo_add_parallax_layer("top"))
	  Graphics.frame_reset
	end
	@dmo_counter += 1
	x = $game_map.display_x * 32
	y = $game_map.display_y * 32
	if @dmo_parallax_info.size == 1
	  @parallax.ox = $game_map.parallax_ox(@parallax.bitmap)
	  @parallax.oy = $game_map.parallax_oy(@parallax.bitmap)
	else
	  @parallax.ox = x
	  @parallax.oy = y
	  @dmo_parallax_sub.ox = x
	  @dmo_parallax_sub.oy = y
	  @dmo_parallax_water.ox = x
	  @dmo_parallax_water.oy = y
	  @dmo_parallax_top.ox = x
	  @dmo_parallax_top.oy = y
	end
  end
end
#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map
  alias dmo_al_pre_transfer pre_transfer
  def pre_transfer
	dmo_al_pre_transfer
	@spriteset.dmo_clear_parallax_cache
  end
end
#==============================================================================
# ■ Game_CharacterBase
#==============================================================================
class Game_CharacterBase
  alias dmo_al_screen_z screen_z
  def screen_z(value = nil)
	return dmo_al_screen_z if !value && !@dmo_screen_z
	@dmo_screen_z || (value && @dmo_screen_z = value)
	return @dmo_screen_z
  end
end
#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● dmo_change_z
  #   changes the z-value of an event
  #	 (value) : the new z-value
  #	 (event) : the event_id
  #--------------------------------------------------------------------------
  def dmo_change_z(value = nil,event = @event_id)
	$game_map.events[event].screen_z(value)
  end
end