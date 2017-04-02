#------------------------------------------------------------------------------#
#  Galv's Layer Graphics
#------------------------------------------------------------------------------#
#  For: RPGMAKER VX ACE
#  Version 1.3
#------------------------------------------------------------------------------#
#  2013-03-22 - Version 1.3 - Fixed bug in y offset movement
#  2013-03-22 - Version 1.2 - Added layers in battles
#  2013-03-17 - Version 1.1 - fixed graphic object bug
#  2013-03-17 - Version 1.0 - release
#------------------------------------------------------------------------------#
#  Create image layers on maps using script calls. These image layers can be
#  used for overlay mapping, moving fogs etc.
#
#  Notes:
#  Once you have created a layer for a map, it will remain at the settings you
#  chose until you change it again. Layers don't carry over from map to map, you
#  will need to create the layer for each map required.
#  I recommend not using too many layers as it could start to cause lag.
#  
#  There are other scripts available that do a similar thing, this is just my
#  implementation of it. I recommend trying the others out, too (as they are
#  possibly better!). I created this more for myself but thought I'd add it to
#  my archive for anyone to use.
#------------------------------------------------------------------------------#
 
#-------------------------------------------------------------------------------
#  SCRIPT CALLS:
#-------------------------------------------------------------------------------
#
#  layer_status(status)    # script enabled if status is true, disabled if false
#
#  del_layer(map_id,layer_id)       # removes a layer graphic from selected map
#
#  layer(map,layer,["Filename",xspeed,yspeed,opacity,z,blend,xoffset,yoffset])
#
#  #  map        - map id the layer is to be on
#  #  layer      - layer number. use different numbers for different layers
#  #  "Filename" - the name of the image located in Graphics/Layers/ folder
#  #  xspeed     - speed the layer will scroll horizontally
#  #  yspeed     - speed the layer will scroll vertically
#  #  opacity    - the opacity of the layer
#  #  z value    - what level the layer is displayed at (ground is 0)
#  #  blend      - 0 is normal, 1 is addition, 2 is subtraction
#  #  xoffset    - Moves the layer at a different amount than the map. Make
#  #  yoffset    - these 0 to fix the layer to the map.
#
#  refresh_layers     # When setting a NEW layer on the CURRENT map, you will
#                     # need to use the refresh_layers script call right after.
#                     # Updating an existing one or setting a layer for another
#                     # map doesn't require refreshing.
#
#-------------------------------------------------------------------------------
#  EXAMPLE SCRIPT CALLS:
#  layer(1,6,["water2",0.3,0.1,120,-5,0,0,0])   # adds/updates layer 6 on map 1
#  layer(2,1,["map2-over",0,0,255,700,0,10,0])  # adds/updates layer 1 on map 2
#
#  layer_status(false)    # turn layers OFF
#  layer_status(true)     # turn layers ON
#-------------------------------------------------------------------------------
 
#-------------------------------------------------------------------------------
#  SCRIPT CALLS for BATTLE layers
#-------------------------------------------------------------------------------
#
#  del_blayer(layer_id)       # Removes a layer from battles.
#
#  refresh_layers             # Use this when adding a new laying during battle
#
#  blayer(layer,["Filename",xspeed,yspeed,opacity,z,blend,xoffset,yoffset])
#
#  #  These script calls add and remove layers that will appear in battle. They
#  #  work the same as map layers without the need for a map id at the start.
#  #  Ideally you would change the layers before combat, but they can be done
#  #  during as well, if you refresh the layers.
#
#-------------------------------------------------------------------------------
 
#-------------------------------------------------------------------------------
#  NO SCRIPT SETTINGS. DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING.
#-------------------------------------------------------------------------------
 
($imported ||= {})["Galv_Layers"] = true
module Cache
  def self.layers(filename)
    load_bitmap("Graphics/Layers/", filename)
  end
end # Cache
 
 
class Spriteset_Map
  def create_layers
    @layer_images = []
    return if !$game_map.layer_status
    return if $game_map.layers[$game_map.map_id].nil?
    $game_map.layers[$game_map.map_id].each_with_index { |layer,i|
      if layer.nil?
        @layer_images.push(nil)
      else
        @layer_images.push(Layer_Graphic.new(@viewport1,i))
      end
    }
  end
 
  def update_layers
    @layer_images.each { |o| o.update if !o.nil? }
  end
   
  def dispose_layers
    @layer_images.each { |o| o.dispose if !o.nil? }
    @layer_images = []
  end
 
  def refresh_layers
    dispose_layers
    create_layers
  end
 
  alias galv_layers_sm_create_parallax create_parallax
  def create_parallax
    galv_layers_sm_create_parallax
    create_layers
  end
  alias galv_layers_sm_dispose_parallax dispose_parallax
  def dispose_parallax
    galv_layers_sm_dispose_parallax
    dispose_layers
  end
 
  alias galv_layers_sm_update_parallax update_parallax
  def update_parallax
    galv_layers_sm_update_parallax
    update_layers
  end
end # Spriteset_Map
 
 
class Spriteset_Battle
  def create_layers
    @layer_images = []
    return if !$game_map.layer_status
    return if $game_map.blayers.nil?
    $game_map.blayers.each_with_index { |layer,i|
      if layer.nil?
        @layer_images.push(nil)
      else
        @layer_images.push(Layer_Graphic.new(@viewport1,i))
      end
    }
  end
 
  def update_layers
    @layer_images.each { |o| o.update if !o.nil? }
  end
   
  def dispose_layers
    @layer_images.each { |o| o.dispose if !o.nil? }
    @layer_images = []
  end
 
  def refresh_layers
    dispose_layers
    create_layers
  end
 
  alias galv_layers_sb_create_battleback2 create_battleback2
  def create_battleback2
    galv_layers_sb_create_battleback2
    create_layers
  end
   
  alias galv_layers_sb_dispose dispose
  def dispose
    dispose_layers
    galv_layers_sb_dispose
  end
 
  alias galv_layers_sb_update update
  def update
    galv_layers_sb_update
    update_layers
  end
end # Spriteset_Battle
 
 
class Game_Map
  attr_accessor :blayers
  attr_accessor :layers
  attr_accessor :layer_status
 
  alias galv_layers_gm_initialize initialize
  def initialize
    galv_layers_gm_initialize
    @layer_status = true
    @layers = { 0 => [] }
    @blayers = []
  end
 
  alias galv_layers_gm_setup setup
  def setup(map_id)
    galv_layers_gm_setup(map_id)
    if SceneManager.scene_is?(Scene_Map)
      @layers[0] = []
      SceneManager.scene.spriteset.refresh_layers
    end
  end
end # Game_Map
 
 
class Scene_Map < Scene_Base
  attr_accessor :spriteset
end # Scene_Map < Scene_Base
 
class Scene_Battle < Scene_Base
  attr_accessor :spriteset
end # Scene_Map < Scene_Base
 
 
class Game_Interpreter
  def refresh_layers
    SceneManager.scene.spriteset.refresh_layers
  end
   
  def layer(map,id,array)
    need_refresh = false
    $game_map.layers[map] ||= []
    need_refresh = true if $game_map.layers[map][id].nil?
    $game_map.layers[map][id] = array
  end
  def del_layer(map,id)
    return if !$game_map.layers[map]
    $game_map.layers[map][id] = nil
    SceneManager.scene.spriteset.refresh_layers
  end
  def layer_status(status)
    $game_map.layer_status = status
    SceneManager.scene.spriteset.refresh_layers
  end
   
  def blayer(id,array)
    need_refresh = false
    $game_map.blayers ||= []
    need_refresh = true if $game_map.blayers[id].nil?
    $game_map.blayers[id] = array
  end
  def del_blayer(id)
    return if !$game_map.blayers
    $game_map.blayers[id] = nil
    SceneManager.scene.spriteset.refresh_layers if SceneManager.scene_is?(Scene_Battle)
  end
   
end # Game_Interpreter
 
 
class Layer_Graphic < Plane
  def initialize(viewport,id)
    super(viewport)
    @id = id
    if SceneManager.scene_is?(Scene_Battle)
      @layers = $game_map.blayers
    else
      @layers = $game_map.layers[$game_map.map_id]
    end
    @layers
    init_settings
  end
 
  def init_settings
    @name = @layers[@id][0]  # filename
    self.bitmap = Cache.layers(@name)
    @width = self.bitmap.width
    @height = self.bitmap.height
    if @layers[0] && @layers[0][@id]
      @movedx = @layers[0][@id][0].to_f  # stored x
      @movedy = @layers[0][@id][1].to_f  # stored y
    else
      @movedx = 0.to_f
      @movedy = 0.to_f
    end
  end
 
  def update
    change_graphic if @name != @layers[@id][0]
    update_opacity
    update_movement
  end
   
  def change_graphic
    @name = @layers[@id][0]
    self.bitmap = Cache.layers(@name)
    @width = self.bitmap.width
    @height = self.bitmap.height
  end
   
  def update_movement
    self.ox = 0 + $game_map.display_x * 32 + @movedx + xoffset
    self.oy = 0 + $game_map.display_y * 32 + @movedy + yoffset
    @movedx += @layers[@id][1]
    @movedy += @layers[@id][2]
    @movedx = 0 if @movedx >= @width
    @movedy = 0 if @movedy >= @height
    self.z = @layers[@id][4]
    self.blend_type = @layers[@id][5]
  end
   
  def xoffset
    $game_map.display_x * @layers[@id][6]
  end
  def yoffset
    $game_map.display_y * @layers[@id][7]
  end
 
  def update_opacity
    self.opacity = @layers[@id][3]
  end
   
  def dispose
    $game_map.layers[0][@id] = [@movedx,@movedy]
    self.bitmap.dispose if self.bitmap
    super
  end
end # Layer_Graphic < Plane