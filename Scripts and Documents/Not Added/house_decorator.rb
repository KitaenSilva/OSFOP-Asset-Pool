#===============================================================================
# Script : Dark's House Decorating System
# Author : Dark Sky ( Nhat Nguyen )
# Forum  : TaoTroChoi.com
# Release on : April 26th 2016
#===============================================================================
# Change log: 
# + 26/4/2016: Release!
#===============================================================================
# Author's Note: Firstly, my English is bad. If you cant understand, pm me!
# Put <can_decorate> in map that you want to mark as an able-to-decorate map.
# Use only ONE Tileset for ALL of able-to-decorate map. ( Strongly recommend )
#===============================================================================
# Useful Script Call(s):
# add_stuff(key) -> Add stuff. 
#   ex: add_stuff(:table) ( :table is a key in Stuff { Stuff[:table] } )
#===============================================================================
module Dark_HouseDecorate
    #--------------------------------------------------------------------------
    # * EDITABLE REGION
    #--------------------------------------------------------------------------
    MOVE_SE       = "Cursor1"     #SE played when press move button.
    OK_SE         = "Item1"       #SE played when press accept button.
    STUFF_TEXT    = "Stuffs"      #Text displayed in Stuff Window.
    ABLE_COLOR    = Color.new(102,255,0,100) #Color for able-to-place region.
    UNABLE_COLOR  = Color.new(255,34,49,100) #Color for unable-to-place region.
    #--------------------------------------------------------------------------
    # * CONFIGURATION REGION
    #--------------------------------------------------------------------------
    Stuff = {}
    Stuff[:table] = {}
    Stuff[:table][:name] = "Table"      #Name of stuff.             
    Stuff[:table][:tiles] = {}          #Require line.
    Stuff[:table][:icon] = 267          #Icon for stuff.
    Stuff[:table][:tiles]["B"] = [[96]] #Tiles array.
                                        # ...["B"] = [[96]] means.
                                        # Tile number 96 in page B
                                        # [[96]] also known as a 2D array
                                        # [[tile1,tile2,...,tilen],[tile1_1,tile2_2,...,tilen_2],...]
                                        # ------------
                                        # eg: n = 3
                                        # Array Show: [[tile1,tile2,tile3],[tile1_1,tile2_1,tile3_1],[tile1_2,tile2_2,tile3_2]]
                                        # Graphic Show:
                                        # tile1   = tile2   = tile3
                                        # tile1_1 = tile2_1 = tile3_1
                                        # tile1_2 = tile2_2 = tile3_2
                                        # Get Tile: Use Dark TileViewer. (Press F8)
    Stuff[:table][:regions] = [3]       # Region that stuff can be put in
    Stuff[:table][:des] = "Just a normal table!" #Description of stuff.
    
    Stuff[:clock] = {}
    Stuff[:clock][:name] = "Clock"
    Stuff[:clock][:tiles] = {}
    Stuff[:clock][:icon] = 190
    Stuff[:clock][:tiles]["B"] = [[160],[168]]
    Stuff[:clock][:regions] = [20,4]
    Stuff[:clock][:des] = "Tick toc tick toc..."
    
    Stuff[:tu] = {}
    Stuff[:tu][:name] = "Wooden shelf"
    Stuff[:tu][:tiles] = {}
    Stuff[:tu][:icon] = 415
    Stuff[:tu][:tiles]["B"] = [[51],[59]]
    Stuff[:tu][:regions] = [3,4]
    Stuff[:tu][:des] = "F*cking shelf made by VN WOOD!"
    # Example for Stuff by Event
    Stuff[:bep_ga] = {}
    Stuff[:bep_ga][:name] = "Gas Stove"
    Stuff[:bep_ga][:tiles] = {}
    Stuff[:bep_ga][:icon] = 267
    Stuff[:bep_ga][:event] = [4,1] # [Map_id,Event_id]
    Stuff[:bep_ga][:regions] = [3]
    Stuff[:bep_ga][:des] = "Old Gas Stove..."
    
    Stuff[:a_picture] = {}
    Stuff[:a_picture][:name] = "A Picture"
    Stuff[:a_picture][:tiles] = {}
    Stuff[:a_picture][:icon] = 100
    Stuff[:a_picture][:event] = [4,3] # [Map_id,Event_id]
    Stuff[:a_picture][:regions] = [20]
    Stuff[:a_picture][:des] = "Old Style Picture."
    
    Stuff[:piano] = {}
    Stuff[:piano][:name] = "Piano"
    Stuff[:piano][:tiles] = {}
    Stuff[:piano][:icon] = 145
    Stuff[:piano][:tiles]["B"] = [[101,102,103],[109,110,111]]
    Stuff[:piano][:regions] = [3,4]
    Stuff[:piano][:des] = "Follow my strings."
    
    # Don't modify this unless you know what are you doing.
    TableH = {}
    TableH["B"] = 5
    TableH["C"] = 6
    TableH["D"] = 7
    TableH["E"] = 8
    Stuff.each_pair do |key,value|
      value[:key] = key
    end
  end
  include Dark_HouseDecorate
  class Spriteset_Map
  alias dark_house_decorate_update update
  alias dark_house_decorate_update_tilemap update_tilemap
  #--------------------------------------------------------------------------
  # * Update Default Stuff
  #--------------------------------------------------------------------------
  def update_default_stuff
    map = load_data(sprintf("Data/Map%03d.rvdata2", $game_map.map_id))
    @default_stuff = {}
    for y in 0...map.data.ysize
      for x in 0...map.data.xsize
        @default_stuff[[x,y]] = map.data[x,y,2]
      end
    end
    @default_stuff.each_pair do |pos,tile|
      @tilemap.map_data[pos[0],pos[1],2] = tile
    end
  end
  #--------------------------------------------------------------------------
  # * Update Tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    dark_house_decorate_update_tilemap()
    if $d_stuff_need_update
      update_default_stuff
      refresh_characters
      $game_map.extract_save_events
      map_grid = $game_system.stuff_map_grid
        if map_grid.has_key?($game_map.map_id)
          for y in 0...map_grid[$game_map.map_id].ysize
            for x in 0...map_grid[$game_map.map_id].xsize
              @tilemap.map_data[x,y,2] = map_grid[$game_map.map_id][x,y] if map_grid[$game_map.map_id][x,y] > 0
            end
          end
        end
        $d_stuff_need_update = false
    end
  end
  #--------------------------------------------------------------------------
  # * Place Stuff Method
  #--------------------------------------------------------------------------
  def place_stuff(key,tile,x,y)
      case key
        when "B"
          @tilemap.map_data[x,y,2] = tile
        when "C"
          @tilemap.map_data[x,y,2] = tile + 255
        when "D"
          @tilemap.map_data[x,y,2] = tile + 255 + 256
        when "E"
          @tilemap.map_data[x,y,2] = tile + 255 + 256*2
        end
    end
  #--------------------------------------------------------------------------
  # * Get Screen X-Coordinates
  #--------------------------------------------------------------------------
  def screen_x(x)
    $game_map.adjust_x(x) * 32 
  end
  #--------------------------------------------------------------------------
  # * Get Screen Y-Coordinates
  #--------------------------------------------------------------------------
  def screen_y(y)
    $game_map.adjust_y(y) * 32 + 32 
  end
  #--------------------------------------------------------------------------
  # * Free Character Sprite
  #--------------------------------------------------------------------------
  alias dark_house_dec_dispose dispose_characters
  def dispose_characters
    dark_house_dec_dispose
    if $stuff_sprite
      $stuff_sprite.bitmap.dispose
      $stuff_sprite.dispose
      $stuff_sprite = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Update save tilemap stuff
  #--------------------------------------------------------------------------
  def update_save_tilemap_stuff
    $game_system.stuff_map_grid[$game_map.map_id] = Table.new($game_map.map.width,$game_map.map.width)
   if $game_system.stuff_map[$game_map.map_id]
     $game_system.stuff_map_grid[$game_map.map_id] = Table.new($game_map.map.width,$game_map.map.width)
     $game_system.stuff_map[$game_map.map_id].each do |obj|
        stuff = obj.item
        x1 = obj.x
        y1 = obj.y
        stuff[:tiles].each_pair do |key,value|
            tiles = value
            tiles.each_with_index do |array,y|
              array.each_with_index do |tile,x|
              map_grid = $game_system.stuff_map_grid[$game_map.map_id]
              map_grid[x1+x,y1+y] = tile
              $d_stuff_need_update = true
            end
          end
        end
      end
    end
    $d_stuff_need_update = true
  end
  def on_choose(item)
    $d_stuff = item.item
    $cur_spawn = false
    $stuff_pos = [item.x,item.y]
    $game_map.set_display_pos($stuff_pos[0] - center_x, $stuff_pos[1] - center_y)
    $stuff_pos_last = [0,0]
  end
  #-----------------------------------------------------------------------------
  # Get Tile Range
  #-----------------------------------------------------------------------------
  def get_tile_range(item)
    max_x = 0
    max_y = 0
    item[:tiles].each_pair do |key,value|
      max_y = value.size
      value.each do |array|
        max_x = [max_x,array.size].max
      end
    end
    return [max_x,max_y]
  end
  #-----------------------------------------------------------------------------
  # Get Stuff image
  #-----------------------------------------------------------------------------
    def stuff_image(key,tiles)
      if !$d_stuff.has_key?(:event)
        $stuff_sprite = Sprite.new
        bitmap = @tilemap.bitmaps[TableH[key]]
        rect  = Rect.new(0,0,32*8,32*18)
        rect2 = Rect.new(32*8,0,32*9,32*18)
        bitmap2 = Bitmap.new(600,2000)
        bitmap2.blt(0,0,bitmap,rect)
        bitmap2.blt(0,32*(9+7),bitmap,rect2)
        $stuff_sprite.bitmap = Bitmap.new(Graphics.width,Graphics.height)
        tiles.each_with_index do |array,y|
          array.each_with_index do |tile,x|
            tile_index = tile - 1 + (key == "B"? 1 : 0)
            rect3 = Rect.new(tile_index % 8 * 32, tile_index / 8 * 32, 32, 32)
            $stuff_sprite.bitmap.blt(x*32,y*32,bitmap2,rect3)
          end
        end
        $stuff_sprite.z = 999
        $stuff_sprite.visible = false
        return
      else
        map = load_data(sprintf("Data/Map%03d.rvdata2", $d_stuff[:event][0]))
        e = Game_Event.new($game_map.map_id, map.events[$d_stuff[:event][1]])
        $stuff_sprite = Sprite_Character.new(@viewport1,e)
        $stuff_sprite.z = 999
        $stuff_sprite.visible = false
        $stuff_sprite.ox = 0
        $stuff_sprite.oy = 0
        map = nil
        e.erase
        e = nil
        return
      end
    end
  #-----------------------------------------------------------------------------
  # Check passable
  #-----------------------------------------------------------------------------
    def check_passable(stuff,x,y,range_x,range_y)
      if !stuff.has_key?(:event)
        counter = 0
        for j in 0...range_y
          for i in 0...range_x
            x1 = x + i
            y1 = y + j
            if stuff[:regions].include?($game_map.region_id(x1, y1)) && @tilemap.map_data[x1,y1,2] == 0 && [x1,y1] != [$game_player.x,$game_player.y] && $game_map.events_xy(x1,y1).size == 0
              counter += 1
            end
          end
        end  
        return counter == range_x*range_y
      else
        if stuff[:regions].include?($game_map.region_id(x, y)) && @tilemap.map_data[x,y,2] == 0 && [x,y] != [$game_player.x,$game_player.y] && $game_map.events_xy(x,y).size == 0
          return true
        else
          return false
        end
      end
    end
  #-----------------------------------------------------------------------------
  # Update Stuff
  #-----------------------------------------------------------------------------     
    def update_stuff
        if $stuff_pos
          _se_move = RPG::SE.new(MOVE_SE)
          _se_accept = RPG::SE.new(OK_SE)
          if Input.trigger?(:Z)
            if $stuff_sprite
              $game_system.user_stuff.push($d_stuff[:key])
              $stuff_sprite.bitmap.dispose
              $stuff_sprite.dispose
              $stuff_sprite = nil
              $stuff_pos = nil
              $d_stuff = nil
              $d_temp_item = nil
              $stuff_pos_last = nil
              $game_map.set_display_pos($game_player.x - center_x, $game_player.y - center_y)
            end
          end
          if $stuff_sprite
            $stuff_sprite.x = screen_x($stuff_pos[0])
            $stuff_sprite.y = screen_y($stuff_pos[1]-1)
          end
          if Input.trigger?(:RIGHT)
            $stuff_pos_last[0] = $stuff_pos[0]
            $stuff_pos[0] += 1
            _se_move.play
          end
          if Input.trigger?(:LEFT)
            $stuff_pos_last[0] = $stuff_pos[0]
            $stuff_pos[0] -= 1
            _se_move.play
          end
          if Input.trigger?(:UP)
            $stuff_pos_last[1] = $stuff_pos[1]
            $stuff_pos[1] -= 1
            _se_move.play
          end
          if Input.trigger?(:DOWN)
            $stuff_pos_last[1] = $stuff_pos[1]
            $stuff_pos[1] += 1
            _se_move.play
          end
        end
        
        if $d_stuff && $stuff_sprite
          x1 = $stuff_pos[0]
          y1 = $stuff_pos[1]
          stuff = $d_stuff
          range_x = get_tile_range(stuff)[0]
          range_y = get_tile_range(stuff)[1]
          if check_passable($d_stuff,x1, y1,range_x,range_y)
            $stuff_sprite.color = ABLE_COLOR
          else
            $stuff_sprite.color = UNABLE_COLOR
          end
        end 
        
        if $d_stuff && !$cur_spawn
            $stuff = $d_stuff
            if !$d_stuff.has_key?(:event)
              $stuff[:tiles].each_pair do |key,value|
                tiles = value
                stuff_image(key,tiles)
                $stuff_sprite.opacity = 180
              end
            else
              stuff_image(nil,nil)
              $stuff_sprite.opacity = 180
            end
            $stuff_sprite.visible = true
            $stuff_sprite.x = screen_x($stuff_pos[0])
            $stuff_sprite.y = screen_y($stuff_pos[1]-1)
            $cur_spawn = true
          end
          
       if Input.trigger?(:L) && $d_stuff && $cur_spawn
          x1 = $stuff_pos[0]
          y1 = $stuff_pos[1]
          stuff = $d_stuff
          range_x = get_tile_range(stuff)[0]
          range_y = get_tile_range(stuff)[1]
            if check_passable(stuff,x1,y1,range_x,range_y) #&& $stuff_sprite
                stuff[:tiles].each_pair do |key,value|
                  tiles = value
                  tiles.each_with_index do |array,y|
                    array.each_with_index do |tile,x|
                      place_stuff(key,tile,x1+x,y1+y)
                      $stuff_sprite.bitmap.dispose if $stuff_sprite
                      $stuff_sprite.dispose if $stuff_sprite
                      $stuff_sprite = nil
                    end
                  end
                end
                if stuff.has_key?(:event)
                  if $game_system.stuff_map[$game_map.map_id]
                    $game_system.stuff_map[$game_map.map_id].push(DStuff.new($d_stuff,$stuff_pos[0],$stuff_pos[1],$game_map.map_id))
                  else
                    $game_system.stuff_map[$game_map.map_id] = [DStuff.new($d_stuff,$stuff_pos[0],$stuff_pos[1],$game_map.map_id)]
                  end
                  $game_map.extract_save_events
                  $stuff_sprite.bitmap.dispose if $stuff_sprite
                  $stuff_sprite.dispose if $stuff_sprite
                  $stuff_sprite = nil
                else
                  if $game_system.stuff_map[$game_map.map_id]
                    $game_system.stuff_map[$game_map.map_id].push(DStuff.new($d_stuff,$stuff_pos[0],$stuff_pos[1],$game_map.map_id))
                  else
                    $game_system.stuff_map[$game_map.map_id] = [DStuff.new($d_stuff,$stuff_pos[0],$stuff_pos[1],$game_map.map_id)]
                  end
                  update_save_tilemap_stuff
                end
                _se_accept.play
                $d_stuff = nil
                $stuff_pos = nil
                $d_temp_item = nil
                $stuff_pos_last = nil
                $game_map.set_display_pos($game_player.x - center_x, $game_player.y - center_y)
              end
        end
    end
  #-----------------------------------------------------------------------------
  # X Coordinate of Screen Center
  #-----------------------------------------------------------------------------
  def center_x
    (Graphics.width / 32 - 1) / 2.0
  end
  #-----------------------------------------------------------------------------
  # Y Coordinate of Screen Center
  #-----------------------------------------------------------------------------
  def center_y
    (Graphics.height / 32 - 1) / 2.0
  end
  #-----------------------------------------------------------------------------
  # Update
  #-----------------------------------------------------------------------------
  def update
    dark_house_decorate_update
    $tilemap = @tilemap
    update_stuff
    if Input.trigger?(:F6)
      if $d_temp_item
        $stuff_sprite.bitmap.dispose
        $stuff_sprite.dispose
        $stuff_sprite = nil
        $game_system.stuff_map[$game_map.map_id].push($d_temp_item)
      end
      if $game_system.stuff_map[$game_map.map_id]
        $d_temp_item = $game_system.stuff_map[$game_map.map_id].shift 
        _change_se = RPG::SE.new("Evasion1")
        _change_se.play
      end
      on_choose($d_temp_item) if $d_temp_item
      update_save_tilemap_stuff if $d_temp_item
      $game_map.extract_save_events
    end
    if Input.trigger?(:F7)
      if $d_temp_item
        $stuff_sprite.bitmap.dispose
        $stuff_sprite.dispose
        $stuff_sprite = nil
        $game_system.stuff_map[$game_map.map_id].unshift($d_temp_item)
      end
      if $game_system.stuff_map[$game_map.map_id]
        $d_temp_item = $game_system.stuff_map[$game_map.map_id].pop 
        _change_se = RPG::SE.new("Evasion1",100,80)
        _change_se.play
      end
      on_choose($d_temp_item) if $d_temp_item
      update_save_tilemap_stuff if $d_temp_item
      $game_map.extract_save_events
    end
  end
end
  
class Game_Player
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    last_real_x = @real_x
    last_real_y = @real_y
    last_moving = moving?
    move_by_input if !$d_stuff
    super
    update_scroll(last_real_x, last_real_y) if !$d_stuff
    update_scroll2 if $stuff_pos && $d_stuff
    update_vehicle
    update_nonmoving(last_moving) unless moving?
    @followers.update
  end
  #--------------------------------------------------------------------------
  # * Scroll Processing
  #--------------------------------------------------------------------------
  def update_scroll2
    ax1 = $game_map.adjust_x($stuff_pos_last[0])
    ay1 = $game_map.adjust_y($stuff_pos_last[1])
    ax2 = $game_map.adjust_x($stuff_pos[0])
    ay2 = $game_map.adjust_y($stuff_pos[1])
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
    $game_map.scroll_up   (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Adding Stuff to Inventory.
  #--------------------------------------------------------------------------
  def add_stuff(key)
    $game_system.user_stuff.push(key)
  end
end


  FADE_SPEED = 15
  class Window_MapShowStuff < Window_Base
    def initialize(x,y,w,h)
      super(x,y,w,h)
      refresh
      self.visible = false
      @_on = nil
      self.opacity = 0
      @wait = 0
      @move_flag = 0
      @pos = 4
    end
    def wait=(duration)
      @wait = duration
    end
    def update_for_wait
      if @wait > 0
        @wait -= 1
      end
    end
    def update_move_window
      if @move_flag == 6
        if self.x + self.width >= Graphics.width
          self.x = Graphics.width - self.width
          @move_flag = 0
          @pos = 6
        else
          self.x += FADE_SPEED 
        end
      end
      if @move_flag == 4 
        if self.x <= 0
          self.x = 0
          @move_flag = 0
          @pos = 4
        else
          self.x -= FADE_SPEED
        end
      end
    end
    def update_pos
      if $stuff_sprite
        if !$stuff_sprite.disposed?
          if $stuff_sprite.x < self.x + self.width && @pos != 6
            @move_flag = 6
          end
          if $stuff_sprite.x > self.x && @pos != 4
            @move_flag = 4
          end
        end
      end
    end
    def string_size(str)
      size = 0
      for i in 0...str.size
        size += text_size(str[i]).width
      end
      return size
    end
    def turn_off
      @_on = false
    end
    def turn_on
      @_on = true
    end
    def update_fade
      if $d_stuff
        turn_on
      end
      if @_on == false
        self.opacity -= FADE_SPEED
        if self.opacity <= 0
          self.visible = false
          self.opacity = 255
          @_on = nil
        end
      else
        self.visible = true
        self.opacity += FADE_SPEED
        if self.opacity >= 255
          @_on = nil
        end
      end
    end
    def update
      super
      refresh
      update_fade if @wait == 0
      update_pos if @wait
      update_move_window if @wait == 0
    end
    def refresh
      contents.clear
      if $d_stuff
        turn_on
        font_color = Color.new(255,153,51)
        stuff_name = "Stuff: "
        contents.font.size = 21
        contents.font.color = font_color
        line_color = Color.new(102,51,0)
        line_bolder = Color.new(200,200,200)
        x = string_size(stuff_name)
        contents.draw_text(0,0,contents.width,line_height,stuff_name)
        contents.draw_text(x,0,contents.width,line_height,$d_stuff[:name])
        contents.font.size = 17
        change_color(normal_color)
        line_w = string_size(stuff_name) + string_size($d_stuff[:name])
        contents.fill_rect(0,24,line_w,5,line_bolder)
        contents.fill_rect(1,25,line_w - 2,3,line_color)
        help_txt = ["Arrow Keys: Move","Q:Place","F6:Next","F7:Previous","D:Back"]
        y = 27
        help_txt.each do |txt|
         contents.draw_text(0,y,contents.width,line_height,txt)
         y += 15
        end
      else
        turn_off
      end
    end
  end
  
  class Scene_Map
    alias dark_house_dec_start2 start
    alias dark_house_dec_update update
    #--------------------------------------------------------------------------
    # * Start Processing
    #--------------------------------------------------------------------------
    def start
      super
      dark_house_dec_start2()
      if !$game_map.decorate_map
        if $window_showstuff
          $window_showstuff.dispose
        end
      else
        $window_showstuff = Window_MapShowStuff.new(0,0,32*6,32*4)
      end
    end
    
    def update
      dark_house_dec_update()
      $window_showstuff.update if $window_showstuff
    end
  end
class Scene_HouseItem < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    $window_showstuff.dispose if $window_showstuff
    $window_showstuff =  nil
    super
    create_background
    create_help_window
    create_command_window
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_background
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
    @background_sprite.bitmap.radial_blur(1, 1)
    @background_sprite.color.set(16, 16, 16, 128)
  end
  #--------------------------------------------------------------------------
  # * Get Currently Selected Item
  #--------------------------------------------------------------------------
  def item
    @cm_window.item
  end
  #--------------------------------------------------------------------------
  # * Free Background
  #--------------------------------------------------------------------------
  def dispose_background
    @background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Create Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.viewport = @viewport
    p @help_window.height
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    wy = @help_window.y + @help_window.height
    @cm_window_txt = Window_HouseItem_Txt.new(0,wy,180,50)
    wh = Graphics.height - @help_window.height - 50
    wy = @help_window.y + @help_window.height + @cm_window_txt.height
    @cm_window = Window_HouseItemList.new(0,wy,180,wh)
    @cm_window.y = @help_window.y + @help_window.height + @cm_window_txt.height
    @cm_window.viewport = @viewport
    @cm_window.activate
    @cm_window.set_handler(:ok, method(:on_choose_complete))
    @cm_window.help_window = @help_window
  end
  
  #-----------------------------------------------------------------------------
  # * X Coordinate of Screen Center
  #-----------------------------------------------------------------------------
  def center_x
    (Graphics.width / 32 - 1) / 2.0
  end
  #-----------------------------------------------------------------------------
  # * Y Coordinate of Screen Center
  #-----------------------------------------------------------------------------
  def center_y
    (Graphics.height / 32 - 1) / 2.0
  end
  #-----------------------------------------------------------------------------
  # * On Choose Complete
  #-----------------------------------------------------------------------------
  def on_choose_complete
    @face = {
    2 => [0,1],
    8 => [0,-1],
    4 => [-1,0],
    6 => [1,0],
    }
    $d_stuff = @cm_window.item
    if !@cm_window.item
      @cm_window.activate
      return 
    end
    $cur_spawn = false
    off = @face[$game_player.direction]
    $stuff_pos = [$game_player.x+off[0],$game_player.y+off[1]]
    $game_map.set_display_pos($stuff_pos[0] - center_x, $stuff_pos[1] - center_y)
    $stuff_pos_last = [0,0] # Important!
    $game_system.user_stuff.delete_at(@cm_window.index)
    if $d_stuff
      return_scene
    end
  end
  #-----------------------------------------------------------------------------
  # * Update
  #-----------------------------------------------------------------------------
  def update
    super
    if Input.trigger?(:B)
      return_scene
    end
  end
end

#==============================================================================
# ** Window_HouseItemList
#==============================================================================
class Window_HouseItemList < Window_Selectable
  include Dark_HouseDecorate
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @data = []
    @sprites = []
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 1
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 180
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  def update
    super
    if Input.trigger?(:C)
      process_ok
    end
  end
  #--------------------------------------------------------------------------
  # * Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    true#enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # * Include in Item List?
  #--------------------------------------------------------------------------
  def include?(item)
    return true
  end
  #--------------------------------------------------------------------------
  # * Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(item)
    true#$game_party.usable?(item)
  end
  #--------------------------------------------------------------------------
  # * Create Item List
  #--------------------------------------------------------------------------
  def make_item_list
    $game_system.user_stuff.each do |key|
      @data.push(Dark_HouseDecorate::Stuff[key])
    end
    @data.push(nil) if include?(nil)
    @data.each do |stuff|
      if stuff
        if !stuff.has_key?(:event)
          stuff[:tiles].each_pair do |key,value|
            tiles = value
            stuff_image(key,tiles,nil)
            @sprite1.x = 544 / 2 - tiles[0].size*32 + 70
            @sprite1.y = 416 / 2 - tiles.size*32
            @sprite1.zoom_x = 3.0
            @sprite1.zoom_y = 3.0
            @sprite1.opacity = 255
            @sprites.push(@sprite1)
            @sprite1 = nil
          end
        else
            stuff_image(nil,nil,stuff)
            @sprite1.x = 544 / 2 - 1*32 + 70
            @sprite1.y = 416 / 2 - 1*32
            @sprite1.zoom_x = 3.0
            @sprite1.zoom_y = 3.0
            @sprite1.opacity = 255
            @sprites.push(@sprite1)
            @sprite1 = nil
        end
      end
    end
    
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select(@data.index($game_party.last_item.object) || 0)
  end
  #--------------------------------------------------------------------------
  # * Refresh Image
  #--------------------------------------------------------------------------
  def refresh_image
    @sprites.each do |sprite|
      sprite.visible = false
    end
    @sprites[index].visible = true if @sprites[index]
  end
  #--------------------------------------------------------------------------
  # * Stuff Image
  #--------------------------------------------------------------------------
  def stuff_image(key,tiles,stuff)
    if !stuff
      @sprite1 = Sprite.new 
      @sprite1.viewport = @viewport
      bitmap = $tilemap.bitmaps[Dark_HouseDecorate::TableH[key]]
      rect  = Rect.new(0,0,32*8,32*18)
      rect2 = Rect.new(32*8,0,32*9,32*18)
      bitmap2 = Bitmap.new(600,2000)
      bitmap2.blt(0,0,bitmap,rect)
      bitmap2.blt(0,32*(9+7),bitmap,rect2)
      @sprite1.bitmap = Bitmap.new(Graphics.width,Graphics.height)
      tiles.each_with_index do |array,y|
        array.each_with_index do |tile,x|
          tile_index = tile - 1 + (key == "B"? 1 : 0)
          rect3 = Rect.new(tile_index % 8 * 32, tile_index / 8 * 32, 32, 32)
          @sprite1.bitmap.blt(x*32,y*32,bitmap2,rect3)
        end
      end
      @sprite1.z = 999
      @sprite1.visible = false
    else
      map = load_data(sprintf("Data/Map%03d.rvdata2", stuff[:event][0]))
      e = Game_Event.new($game_map.map_id, map.events[stuff[:event][1]])
      @sprite1 = Sprite_Character.new(@viewport,e)
      @sprite1.z = 999
      @sprite1.visible = false
      @sprite1.ox = 0
      @sprite1.oy = 0
      map = nil
      e.erase
      e.refresh
      e = nil
    end
  end
  #--------------------------------------------------------------------------
  # * Item Height
  #--------------------------------------------------------------------------
  def item_height
    return 32
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    if @sprite1
      @sprite1.bitmap.dispose
      @sprite1.dispose
    end
    @sprites.each do |sprite|
      if sprite
        sprite.dispose
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      contents.font.size = 18
      draw_text(rect.x + 28, rect.y + 2,210,32,item[:name])
      draw_icon(item[:icon],rect.x + 1,rect.y + 3)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    if item
      @help_window.set_text(item[:des])
    else
      @help_window.set_text("")
    end
    refresh_image 
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end

class Window_HouseItem_Txt < Window_Base
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  def initialize(x,y,width,height)
    super(x,y,width,height)
    draw_text
  end
  #--------------------------------------------------------------------------
  # * Draw text
  #--------------------------------------------------------------------------
  def draw_text
    contents.clear
    str = Dark_HouseDecorate::STUFF_TEXT
    contents.draw_text(contents.rect,str,1)
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================
NOTE_TOKEN = "<can_decorate>"
class Game_Map
  attr_accessor :map
  attr_accessor :map_id
  attr_accessor :decorate_map
  alias dark_house_dec_game_map_zx_setup setup
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map_id)
    dark_house_dec_game_map_zx_setup(map_id)
    @trash_ev = []
    $d_stuff_need_update = true
    if @map.note == NOTE_TOKEN
      @decorate_map = true
    else
      @decorate_map = false
    end
    if !$game_system.stuff_map_grid.has_key?(map_id) 
      $game_system.stuff_map_grid[map_id] = Table.new(@map.width,@map.height)#Dark_Table.new(@map.width,@map.height)
    end
  end
  #--------------------------------------------------------------------------
  # * Thêm Event vào Biến
  #--------------------------------------------------------------------------
  def insert_stuff_map_ev(item,x,y)
    if $game_system.stuff_map[@map_id]
      $game_system.stuff_map[@map_id].push(DStuff.new(item,x,y,@map_id))
    else
      $game_system.stuff_map[@map_id] = [DStuff.new(item,x,y,@map_id)]
    end
    extract_save_events
  end
  #--------------------------------------------------------------------------
  # * Giải nén Event đã lưu
  #--------------------------------------------------------------------------
  def extract_save_events
    @events.each_pair do |key,value|
      if value.is_decorate_item
        value.erase
        value.refresh
        @trash_ev.push(key)
      end
    end  
    @trash_ev.each do |ev|
      @events.delete(ev)
    end
    SceneManager.scene.refresh_characters
    if $game_system.stuff_map[@map_id]
      $game_system.stuff_map[@map_id].each do |event|
        if event.item.has_key?(:event)
          map = event.item[:event][0]
          event_id = event.item[:event][1]
          x = event.x
          y = event.y
          d_add_decorate_event(map,event_id,x,y)
        end
      end
    end
    SceneManager.scene.update_tilemap
  end
  #--------------------------------------------------------------------------
  # * Thêm Event từ Map khác vào
  #--------------------------------------------------------------------------
  def d_add_decorate_event(mapid, eventid, x, y)
    map = load_data(sprintf("Data/Map%03d.rvdata2", mapid))
    e = Game_Event.new(mapid, map.events[eventid])
    e.is_decorate_item = true
    e.moveto(x,y)
    e.event.id = @events.length + 1
    @events[e.event.id] = e
    p "Event Length : #{@events.length}" if $TEST
    SceneManager.scene.refresh_characters
  end
end
class Game_Event
  attr_accessor :event
  def id
    return @event.id
  end
end

class Scene_Map
  alias dark_house_dec_start start
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    dark_house_dec_start()
  end
  #--------------------------------------------------------------------------
  # * Determine if Menu is Called due to Cancel Button
  #--------------------------------------------------------------------------
  alias dark_house_dec_update_call_menu update_call_menu
  def update_call_menu
    dark_house_dec_update_call_menu if !$d_stuff
    map_note = $game_map.map.note
    if Input.trigger?(:Z) && !$d_stuff && map_note.include?(NOTE_TOKEN)
      SceneManager.call(Scene_HouseItem)
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh Characters
  #--------------------------------------------------------------------------
  def refresh_characters
    @spriteset.refresh_characters if @spriteset
  end
  #--------------------------------------------------------------------------
  # * Khởi tạo lại Tilemap
  #--------------------------------------------------------------------------
  def update_tilemap
    @spriteset.dispose_tilemap if @spriteset
    @spriteset.create_tilemap if @spriteset
  end
end

class Game_Event
  attr_accessor :is_decorate_item
end

#===============================================================================
# Dark House Decorating Variables
# Very Important. Heart of this system!
#===============================================================================
class Game_System
  attr_accessor :user_stuff
  attr_accessor :stuff_map
  attr_accessor :stuff_map_grid
  attr_accessor :stuff_map_ev
  alias dark_house_decorating_initialize_save initialize
  def initialize
    @user_stuff = []
    @stuff_map = {}
    @stuff_map_grid = {}
    @stuff_map_ev = {}
    dark_house_decorating_initialize_save()
  end
end
class DStuff
  attr_accessor :item
  attr_accessor :x
  attr_accessor :y
  attr_accessor :map_id
  def initialize(item,x,y,map_id)
    @item = item
    @x = x
    @y = y
    @map_id = map_id
  end
end
#===============================================================================
# HEART OF THE SYSTEM
#===============================================================================