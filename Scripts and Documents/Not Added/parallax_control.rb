# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Ultimate Parallax Control V1.0
#
# By: ☆GDS☆
#
# Site: ***************
# Requires: n/a
# Lag : none
#==============================================================================
# ▼ Updates
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# 2012.21.05 - Script istart and finish
#
#==============================================================================
# ▼ Introduction
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# this is a script that joins all functions for parallaxes on ace, without any
#of its drawback on a single script
#no need for script calls, <notetags>, or switches/variables
#
#==============================================================================
#==============================================================================
# ▼ Licence
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# do whatever you wnat with if, just dont forget to credit me
#
#==============================================================================
#==============================================================================
# ¥ Configuraçôes
#==============================================================================
module GDS_Parallax
module Parallax
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  #All parallaxes are fixed by defaut now,
  #if want the default movement of the parallaxex just put the map id here
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  FIXED_Parallax =[2,3,  #<=|Id of the map that will not be fixed
] #
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # sky layer,
  # a layer that stays on top of everything and dont move
  #
  # needs a image on "\Graphics\Parallaxes\"
  # named "X"_layer2  where"x" is the map ID
  # ex: "\Graphics\Parallaxes\4_layer2"
  #
  # Parallax2  <= Put the Id of the map that will use the Sky layer
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Parallax2 = [4,3,8, #<=|maps with Sky parallax
]
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Light Layer
  # a layer that stays on top of everything, but the sky layer
  # can and cannot move
  #
  # needs a image on "\Graphics\Parallaxes\"
  # named "X"_light  where"x" is the map ID
  # ex: "\Graphics\Parallaxes\4_light"
  #
  #
  # Light <= Put the Id of the map that will use the Light layer
  #
  #
  #:Flicker_Light
  #
  # 0		 => It wont move
  # 1 oo more => iot will shake, any mumner bigger than 1, will have a ugly effect
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Light = [14,				  #<=|Id of the map that will use the Light layer
]
  Flicker_Light = 1			 #<=|movement?

  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Shadow Layer
  # a layer that stays on top of everything, but the SKY and LIGHT layers
  # can and cannot move
  #
  # needs a image on "\Graphics\Parallaxes\"
  # named "X"_shadow  where"x" is the map ID
  # ex: "\Graphics\Parallaxes\4_shadow"
  #
  #
  # Shadow <= Put the Id of the map that will use the Shadow layer
  #
  #
  #:Flicker_Shadow
  #
  # 0		 => It wont move
  # 1 oo more => iot will shake, any mumner bigger than 1, will have a ugly effect
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Shadow = [4,			  #<=|Id of the map that will use the shadow layer
]
  Flicker_Shadow = 0	    #<=|movement?

  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # GroundLayer
  #a layer that stays above the Tiles, (map), and below any event and player
  #
  # needs a image on "\Graphics\Parallaxes\"
  # named "X"_Ground  where"x" is the map ID
  # ex: "\Graphics\Parallaxes\4_ground"
  #
  #
  # Ground <= Put the Id of the map that will use the ground layer
  #
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Ground = [14,  #<=|Id of the map that will use the ground layer

 
]
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  # Switches and variables
  #
  # Switches
  #
  # define if the layer will or will not be displayed
  # if you dont want to use put "nil"
  #
  # Variables
  # chance de imagen that a parallax will use.
  #EX:
  #  map 4 light layer is named: "4_light"
  #
  #  but if you want to use a variable to alter the light layers:
  #
  # variable value = 0 name = "4_light
  # variable valuel = 1 name = "4-1_light
  # Vvariable value= 5 name = "4-5_light
  #
  # you will add a "-X"after the map number, where "x" is the variable current value
  #
  #
  #
  #	   atention:
  #
  #switches will work as soon you turn it on/off
  # Variables need to change the map first
  #=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  SWITCH_SKY = nil	   
  SWITCH_LIGHT = nil    
  SWITCH_SHADOW = nil     
  SWITCH_GROUND = nil
 
  VARIABLE_SKY = nil	  
  VARIABLE_LIGHT = nil   
  VARIABLE_SHADOW = nil    
  VARIABLE_GROUND = nil     
#==============================================================================
# End of configuration
#==============================================================================
#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================
end
end
class Spriteset_Map
  include GDS_Parallax::Parallax
  #=============================================================================
  # * alias method create_parallax
  #=============================================================================
  alias create_parallax_gds create_parallax
  def create_parallax
    create_parallax_gds
    create_parallaxes
    @do_it1 = true;@do_it2 = true;@do_it3 = true;@do_it4 = true
  end
  def create_parallaxes
    map = $game_map.map_id
    @maps = $game_map.map_id
    ;@check1 = true;@check2 = true;@check3 = true;@check4 = true
    @fixed_p = false;@create1 = false;@create2 = false;@create2 = false;@create3 = false;@create4 = false
    for i in FIXED_Parallax;@fixed_p = true if i == map;end
    for i in Parallax2;@create1 = true if i == map;end
    for i in Light;@create2 = true if i == map;end
    for i in Shadow;@create3 = true if i == map;end
    for i in Ground;@create4 = true if i == map;end
    @parallax1 = Plane.new(@viewport1) if @create1 == true
    @parallax1.z = 203 if @create1 == true;@check1 = false
    @parallax2 = Plane.new(@viewport1) if @create2 == true
    @parallax2.z = 202 if @create2 == true ;@check2 = false
    @parallax3 = Plane.new(@viewport1) if @create3 == true
    @parallax3.z = 201 if @create3 == true;@check3 = false
    @parallax4 = Plane.new(@viewport1) if @create4 == true
    @parallax4.z = 50 if @create4 == true ;@check4 = false
    on1= false
    on2= false
    on3= false
    on4= false
  end
  #=============================================================================
  # * new method create_and_dispose
  # * new method check_for_dispose
  #=============================================================================
  def create_and_dispose
    @parallax1.dispose if @on1 == true
    @parallax2.dispose if @on2 == true
    @parallax3.dispose if @on3 == true
    @parallax4.dispose if @on4 == true
    create_parallaxes
    p "done"
  end
  def check_for_dispose
   create_and_dispose if @maps != $game_map.map_id
 end
  #=============================================================================
  # * new method check_for_swicthes
  #=============================================================================
 
 
 
 
 
  #=============================================================================
  # * alias method dispose_parallax  
  #=============================================================================
  alias dispose_parallax_gds dispose_parallax
  def dispose_parallax
    @parallax1.dispose if @on1 == true
    @parallax2.dispose if @on2 == true
    @parallax3.dispose if @on3 == true
    @parallax4.dispose if @on4 == true
    dispose_parallax_gds
  end
  #=============================================================================
  # * overwrite method update_parallax
  #=============================================================================
  def update_parallax
    check_for_dispose
    @parallax1.visible= $game_switches[SWITCH_SKY] if SWITCH_SKY != nil
    @parallax2.visible= $game_switches[SWITCH_LIGHT] if SWITCH_LIGHT != nil
    @parallax3.visible= $game_switches[SWITCH_SHADOW] if SWITCH_SHADOW != nil
   @parallax4.visible= $game_switches[SWITCH_GROUND] if SWITCH_GROUND != nil
    
    if @parallax_name != $game_map.parallax_name
	  @parallax_name = $game_map.parallax_name
	  @parallax.bitmap.dispose if @parallax.bitmap
	  @parallax.bitmap = Cache.parallax(@parallax_name)
	  Graphics.frame_reset
    end
    if @create1 == true and @check1 == false
	  @parallax1.bitmap.dispose if @parallax1.bitmap
	  sky = $game_map.map_id.to_s
	  if VARIABLE_SKY != nil
	    sky = $game_map.map_id.to_s+"-"+$game_variables[VARIABLE_SKY].to_s
	    sky = $game_map.map_id.to_s if $game_variables[VARIABLE_SKY] == 0
	  end
	  @parallax1.bitmap = Cache.parallax(sky+"_layer2")
	  Graphics.frame_reset
	  @check1 = true;@on1 = true
    end
    if @create2 == true and @check2 == false
	  @parallax2.bitmap.dispose if @parallax2.bitmap
	   light = $game_map.map_id.to_s
	  if VARIABLE_LIGHT != nil
	    light = $game_map.map_id.to_s+"-"+$game_variables[VARIABLE_LIGHT].to_s
	    light = $game_map.map_id.to_s if $game_variables[VARIABLE_LIGHT] == 0
	  end
	  @parallax2.bitmap = Cache.parallax(light+"_light")
	  Graphics.frame_reset
	  @check2 = true;@on2 = true
    end
    if @create3 == true and @check3 == false
	  @parallax3.bitmap.dispose if @parallax3.bitmap
	  shadow = $game_map.map_id.to_s
	  if VARIABLE_SHADOW != nil
	    shadow = $game_map.map_id.to_s+"-"+$game_variables[VARIABLE_SHADOW].to_s
	    shadow = $game_map.map_id.to_s if $game_variables[VARIABLE_SHADOW] == 0
	  end
	  @parallax3.bitmap = Cache.parallax(shadow+"_shadow")
	  Graphics.frame_reset
	  @check3 = true;@on3 = true
    end
	 if @create4 == true and @check4 == false
	  @parallax4.bitmap.dispose if @parallax4.bitmap
	  ground = $game_map.map_id.to_s
	  if VARIABLE_GROUND != nil
	    ground = $game_map.map_id.to_s+"-"+$game_variables[VARIABLE_GROUND].to_s
	    ground = $game_map.map_id.to_s if $game_variables[VARIABLE_GROUND] == 0
	  end
	  @parallax4.bitmap = Cache.parallax(ground+"_ground")
	  Graphics.frame_reset
	  @check4 = true;@on4 = true
    end
	  @parallax1.ox = $game_map.display_x * 32  if @create1 == true
	  @parallax1.oy = $game_map.display_y * 32  if @create1 == true
   
	  @parallax2.ox = $game_map.display_x * 32 + rand(Flicker_Light) if @create2 == true
	  @parallax2.oy = $game_map.display_y * 32 + rand(Flicker_Light) if @create2 == true
	  
	  @parallax3.ox = $game_map.display_x * 32 + rand(Flicker_Shadow) if @create3 == true
	  @parallax3.oy = $game_map.display_y * 32 + rand(Flicker_Shadow) if @create3 == true
	  
	  @parallax4.ox = $game_map.display_x * 32  if @create4 == true
	  @parallax4.oy = $game_map.display_y * 32  if @create4 == true
	  
	  if @fixed_p == true
	  @parallax.ox = $game_map.parallax_ox(@parallax.bitmap)
	  @parallax.oy = $game_map.parallax_oy(@parallax.bitmap)
    else
	  @parallax.ox = $game_map.display_x * 32
	  @parallax.oy = $game_map.display_y * 32
    end
  end
end