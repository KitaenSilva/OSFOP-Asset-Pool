#==========================================================================
# TileViewer 1.0 -
# DARK SKY -
# PERFECT TOOL FOR DARK'S HOUSE DECORATING SYSTEM -
#==========================================================================
# Put this Below Dark's House Decorating System Script.
#--------------------------------------------------------------------------
# F8 : Open Scene
#==========================================================================
class Scene_TileViewer < Scene_Base
  include Dark_HouseDecorate
  TILE_PAGE = ["B","C","D","E"]
  #--------------------------------------------------------------------------
  # * Create Tilemap
  #--------------------------------------------------------------------------
  def create_tilemap
    @viewport1 = Viewport.new
    @tilemap = Tilemap.new(@viewport1)
    @map = load_data(sprintf("Data/Map%03d.rvdata2", $game_map.map_id))
    @tilemap.map_data = @map.data
    load_tileset
  end
  #--------------------------------------------------------------------------
  # * Load Tileset
  #--------------------------------------------------------------------------
  def load_tileset
    @tileset = $game_map.tileset
    @tileset.tileset_names.each_with_index do |name, i|
      @tilemap.bitmaps[i] = Cache.tileset(name)
    end
    @tilemap.flags = @tileset.flags
  end
  #--------------------------------------------------------------------------
  # * Terminate
  #--------------------------------------------------------------------------
  def terminate
    super
    @tilemap.dispose
    @sprite.bitmap.dispose
    @sprite.dispose
    @contents.dispose
  end
  #--------------------------------------------------------------------------
  # * Change key
  #--------------------------------------------------------------------------
  def change_key
    if @sprite
      @sprite.dispose
    end
    if @contents
      @contents.dispose
    end
    @key = @key = TILE_PAGE[@index]
    @sprite = Sprite.new
    bitmap = @tilemap.bitmaps[TableH[@key]]
    rect  = Rect.new(0,0,32*8,32*18)
    rect2 = Rect.new(32*8,0,32*9,32*18)
    bitmap2 = Bitmap.new(600,2000)
    bitmap2.blt(0,0,bitmap,rect)
    bitmap2.blt(0,32*(9+7),bitmap,rect2)
    bitmap2.font.size = 20
    counter = @key == "B"? 0 : 1
    for j in 0..((9+7)*2 - 1)
      for i in 0..(7)
        bitmap2.draw_text(i*32+5,j*32,32,32,"#{counter}")
        counter += 1
      end
    end
    @sprite.bitmap = bitmap2
    @sprite.x = 544.0 / 2 - 32*7 / 2 + 100
    @sprite.z = 999
    @contents = Sprite.new
    @contents.viewport = @viewport1
    @contents.bitmap = Bitmap.new(544,416)
    @contents.bitmap.font.size = 17
    @contents.bitmap.font.name = ["SP3 - Hero",Font.default_name]
    @contents.bitmap.font.bold = true
    @contents.bitmap.fill_rect(0,0,544,416,Color.new(0,0,0,200))
    @contents.bitmap.fill_rect(255,0,264,416,Color.new(0,0,0,230))
    @contents.bitmap.draw_text(10,0,500,32,"TileViewer 1.0 by Dark Sky")
    @contents.bitmap.fill_rect(10,22,50*4,1,Color.new(255,255,255,200))
    @contents.bitmap.font.size = 16
    @contents.bitmap.font.bold = false
    y = 14
    @contents.bitmap.draw_text(10,y,500,32,"Current Tile Page: #{@key}")
    y += 12
    @help_txt = ["Map_ID : #{$game_map.map_id}","UP/DOWN Key: Move Up/Down","X: Back","LEFT/RIGHT: Change TILE Page","SHIFT: Speed Up!"]
    @help_txt.each do |text|
      @contents.bitmap.draw_text(10,y,500,32,text)
      y += 12
    end
  end
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    super
    create_tilemap
    @index = 0
    @key = TILE_PAGE[@index]
    @speed = 1
    change_key
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if Input.press?(:A)
      @speed = 5
    else
      @speed = 1
    end
    if Input.trigger?(:RIGHT)
      @index += 1 
      if @index > TILE_PAGE.size - 1
        @index = 0
      end
      change_key
    end
    if Input.trigger?(:LEFT)
      @index -= 1 
      if @index < 0
        @index = TILE_PAGE.size - 1
      end
      change_key
    end
    if Input.press?(:UP)
      @sprite.oy -= @speed
    end
    if Input.press?(:DOWN)
      @sprite.oy += @speed
    end
    if Input.press?(:B)
      @sprite.bitmap.dispose
      @sprite.dispose
      return_scene
    end
  end
end
#==========================================================================
# * Scene Map
#==========================================================================
class Scene_Map
  alias dark_stuff_tileviewer_update update
  def update(*args)
    dark_stuff_tileviewer_update(*args)
    if Input.trigger?(:F8) && $TEST
      SceneManager.call(Scene_TileViewer)
    end
  end
end