=begin
CSCA Teleport
version: 1.0.0 (Released: Sometime in 2013)
Created by: Casper Gaming (http://www.caspergaming.com/)
================================================================================
Compatibility:
Made for RPGVXAce
IMPORTANT: ALL CSCA Scripts should be compatible with each other unless
otherwise noted.

Requires CSCA Core Script v1.0.8+
LINK: http://www.rpgmakervxace.net/topic/6879-csca-core-script/

Optional toast windows require CSCA Toast Manager(v1.1.1+)
LINK: http://www.rpgmakervxace.net/topic/13960-csca-toast-manager/
================================================================================
FEATURES
Creates a teleport scene. Can be called from a skill/item, or through an event.
-Unlock teleport destinations
-Unlimited teleport destinations
-Require MP or item cost for each teleport
-Display an image of the teleport
================================================================================
SETUP
Set up required. Instructions below.
================================================================================
CREDIT:
Free to use in noncommercial games if credit is given to:
Casper Gaming (http://www.caspergaming.com/)

To use in a commercial game, please purchase a license here:
http://www.caspergaming.com/licenses.html
================================================================================
TERMS:
http://www.caspergaming.com/terms_of_use.html
================================================================================
=end
module CSCA
  module TELE
    TELEPORT, DESCRIPTION = [], []
#==============================================================================
# ** Begin Script Instructions (Setup farther down)
#==============================================================================
#==============================================================================
# ** Script Calls
#==============================================================================
# IMPORTANT! Refer to teleports by their symbol in your script calls!
#------------------------------------------------------------------------------
# discover_teleport(symbol)
#
# Changes the discovered status of the teleport referred to by the symbol param
# to true. Alternatively, you can also set the discovery status to false by adding
# a false parameter after the symbol parameter.
# ex: discover_teleport(symbol, false)
#------------------------------------------------------------------------------
# call_teleport_scene
#
# Simple way to call the teleport scene. If you want to restrict the teleports
# available in the scene, you can add the type parameter to this script call and
# only teleports of that type will appear in the list.
# ex: call_teleport_scene(:all)
#==============================================================================
# ** Which actor's MP is used
#==============================================================================
# The party leader's MP will be used for teleports in all cases except when the
# scene is called from the skill menu. In that case, it will use the actor who
# used the skill's MP for the teleport.
#==============================================================================
# ** The :all scene type
#==============================================================================
# If no type is given when the scene is called, or if the type given is :all,
# all teleports will be displayed regardless of their type.
#==============================================================================
# ** Begin Setup
#==============================================================================
#==============================================================================
# ** Description Setup
#==============================================================================
   #DESCRIPTION[x] = ["Descriptive text.", "Supports up to 3 lines of text."]
    DESCRIPTION[0] = ["Descriptive text.", "Supports up to 3 lines of text.", "Third line here."]
#==============================================================================
# ** Teleport Setup
#==============================================================================
    #TELEPORT[x] = {
    #:symbol => :test,  # The symbol used to refer to this teleport in script calls.
    #:type => :skill,   # The type of teleport.
    #:name => "Kuwait", # The name of the teleport
    #:description => DESCRIPTION[0], # Teleport description
    #:image => "Town1.png", # The image displayed.
    #:discovered => false,  # Initial discovery status.
    #:map => 1,             # The map the teleport goes to.
    #:x => 0,               # The x-coordinate the teleport goes to.
    #:y => 0,               # The y-coordinate the teleport goes to.
    #:d => 0, # The direction the teleport leaves the player facing. 2 = down, 4 = left, 6 = right, 8 = up
    #:mp => 5,              # The amount of MP the teleport costs. Set to 0 for no MP cost.
    #:item => nil           # Item ID the teleport costs. Set to nil to have no item cost.
    #}
    
    TELEPORT[0] = {
    :symbol => :test,
    :type => :skill,
    :name => "Kuwait",
    :description => DESCRIPTION[0],
    :image => "Town1.png",
    :discovered => false,
    :map => 1,
    :x => 0,
    :y => 0,
    :d => 0,
    :mp => 5,
    :item => nil
    }
#==============================================================================
# ** Misc. Setup
#==============================================================================
    HEADER = "Teleports"            # Header text
    FOLDER = "Graphics/Teleports/"  # Folder that contains teleport image files
    HAS_COSTS = true       # Set to true if any of your teleports cost items/MP
    SHOW_UNDISCOVERED = false    # Include even undiscovered teleports in list?
    UNDISCOVERED_TEXT = "? ? ? ? ?"  # Text to represent undiscovered teleports
    FREE = "Free!"         # Text shown in cost window if teleport has no cost.
    SHOW_TOASTS = true # Show toasts upon teleport discovery (Req. CSCA Toast Manager v1.1.1+).
    DISCOVER_TEXT = "Teleport Discovered!" # Text shown in toast window upon discovery.
#==============================================================================
# ** End Setup
#==============================================================================
  end
end
#==============================================================================
# ** CSCA_Teleport
#------------------------------------------------------------------------------
# Stores teleport data.
#==============================================================================
class CSCA_Teleport
  attr_accessor :discovered
  attr_reader :symbol, :name, :description, :image, :map, :x, :y, :d, :mp, :item, :type
  #--------------------------------------------------------------------------
  # Object Initialization
  #--------------------------------------------------------------------------
  def initialize(teleport)
    @symbol = teleport[:symbol]
    @type = teleport[:type]
    @name = teleport[:name]
    @description = teleport[:description]
    @image = teleport[:image]
    @map = teleport[:map]
    @x = teleport[:x]
    @y = teleport[:y]
    @d = teleport[:d]
    @mp = teleport[:mp]
    @item = teleport[:item]
    @discovered = teleport[:discovered]
  end
end
#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
# Get teleport type for items/skills
#==============================================================================
class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # Check if skill/item has teleport function
  #--------------------------------------------------------------------------
  def csca_has_teleport?
    @note =~ /<csca tele: (.*)>/i
  end
  #--------------------------------------------------------------------------
  # Get teleport type for scene
  #--------------------------------------------------------------------------
  def csca_teleport_type
    @note =~ /<csca tele: (.*)>/i
    return $1.to_sym
  end
end
#==============================================================================
# ** CSCA_Core
#------------------------------------------------------------------------------
# Added teleportation handling
#==============================================================================
class CSCA_Core
  attr_reader :teleports
  #--------------------------------------------------------------------------
  # Alias Method; Object Initialization
  #--------------------------------------------------------------------------
  alias :csca_tele_initialize :initialize
  def initialize
    csca_tele_initialize
    initialize_teleports
  end
  #--------------------------------------------------------------------------
  # Initialize Teleports
  #--------------------------------------------------------------------------
  def initialize_teleports
    @teleports = []
    CSCA::TELE::TELEPORT.each do |teleport|
      @teleports.push(CSCA_Teleport.new(teleport))
    end
  end
  #--------------------------------------------------------------------------
  # Get teleport
  #--------------------------------------------------------------------------
  def get_teleport(symbol)
    @teleports.each do |teleport|
      return teleport if teleport.symbol == symbol
    end
  end
end
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Addition of commands related to managing teleports
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # Discover Teleport (and forget teleport)
  #--------------------------------------------------------------------------
  def discover_teleport(symbol, discover = true)
    teleport = $csca.get_teleport(symbol)
    teleport.discovered = discover
    $csca.reserve_toast([:tele_disc, teleport]) if $imported["CSCA-ToastManager"] && CSCA::TELE::SHOW_TOASTS && discover
  end
  #--------------------------------------------------------------------------
  # Call teleport scene
  #--------------------------------------------------------------------------
  def call_teleport_scene(scene_type = :all)
    SceneManager.call(CSCA_Scene_Teleport)
    SceneManager.scene.prepare(scene_type)
  end
end
#==============================================================================
# ** CSCA_Scene_Teleport
#------------------------------------------------------------------------------
#  Handles the quest scene.
#==============================================================================
class CSCA_Scene_Teleport < Scene_MenuBase
  #--------------------------------------------------------------------------
  # Start Processing
  #--------------------------------------------------------------------------
  def prepare(scene_type = :all, actor = $game_party.leader)
    @scene_type = scene_type
    @actor = actor
  end  
  #--------------------------------------------------------------------------
  # Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    if @scene_type.nil?
      SceneManager.goto(Scene_Map)
      $csca.report_error("Scene not prepared.", "CSCA Teleport", "Please include the scene_type parameter in your script call, or item/skill note tag.")
    end
    create_head_window
    create_select_window
    create_cost_window if CSCA::TELE::HAS_COSTS
    create_description_window
    create_image_window
  end
  #--------------------------------------------------------------------------
  # Create Header Window
  #--------------------------------------------------------------------------
  def create_head_window
    @head_window = CSCA_Window_Header.new(0,0,CSCA::TELE::HEADER)
  end
  #--------------------------------------------------------------------------
  # Create Selection Window
  #--------------------------------------------------------------------------
  def create_select_window
    y = @head_window.height
    w = Graphics.width/3
    height_modifier = CSCA::TELE::HAS_COSTS ? 0 : y*2
    h = Graphics.height-y*3 + height_modifier
    @select_window = CSCA_Window_TeleportSelect.new(0, y, w, h, @scene_type, @actor)
    @select_window.viewport = @viewport
    @select_window.set_handler(:cancel, method(:return_scene))
    @select_window.set_handler(:ok, method(:do_teleport))
  end
  #--------------------------------------------------------------------------
  # Create Cost Window
  #--------------------------------------------------------------------------
  def create_cost_window
    y = @head_window.height + @select_window.height
    w = @select_window.width
    h = @head_window.height * 2
    @cost_window = CSCA_Window_TeleportCost.new(0, y, w, h)
    @cost_window.viewport = @viewport
    @select_window.cost_window = @cost_window
  end
  #--------------------------------------------------------------------------
  # Create Description Window
  #--------------------------------------------------------------------------
  def create_description_window
    x = @select_window.width
    y = @head_window.height
    w = Graphics.width - @select_window.width
    h = @head_window.height * 2
    @description_window = CSCA_Window_TeleportDescription.new(x, y, w, h)
    @description_window.viewport = @viewport
    @select_window.help_window = @description_window
  end
  #--------------------------------------------------------------------------
  # Create Image Window
  #--------------------------------------------------------------------------
  def create_image_window
    x = @select_window.width
    y = @head_window.height + @description_window.height
    w = Graphics.width - @select_window.width
    h = Graphics.height - @head_window.height - @description_window.height
    @image_window = CSCA_Window_TeleportImage.new(x, y, w, h)
    @image_window.viewport = @viewport
    @select_window.image_window = @image_window
    @select_window.activate
  end
  #--------------------------------------------------------------------------
  # Execute teleport
  #--------------------------------------------------------------------------
  def do_teleport
    teleport = @select_window.item
    subtract_costs(teleport)
    $game_player.reserve_transfer(teleport.map, teleport.x, teleport.y, teleport.d)
    SceneManager.goto(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # Take away MP/
  #--------------------------------------------------------------------------
  def subtract_costs(teleport)
    unless teleport.item.nil?
      $game_party.lose_item($data_items[teleport.item], 1)
    end
    unless teleport.mp == 0
      @select_window.actor.mp -= teleport.mp
    end
  end
end
#==============================================================================
# ** CSCA_Window_TeleportSelect
#------------------------------------------------------------------------------
#  Displays available teleports.
#==============================================================================
class CSCA_Window_TeleportSelect < Window_Selectable
  attr_accessor :actor
  #--------------------------------------------------------------------------
  # Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, category, actor)
    super(x, y, width, height)
    @category = category
    @actor = actor
    @data = []
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # Get total amount of teleports in list
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # Get selected teleport
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # Display in Enabled State?
  #--------------------------------------------------------------------------
  def enable?(teleport)
    return false if teleport.nil? || !teleport.discovered
    return false unless teleport.item.nil? || $game_party.has_item?($data_items[teleport.item])
    return false if @actor.mp < teleport.mp
    return true
  end
  #--------------------------------------------------------------------------
  # Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # Determine if teleport is included in list
  #--------------------------------------------------------------------------
  def include?(teleport)
    return false if !teleport.discovered && !CSCA::TELE::SHOW_UNDISCOVERED
    return true if @category == :all
    return true if @category == teleport.type
    return false
  end
  #--------------------------------------------------------------------------
  # Populate Teleport List
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $csca.teleports.select {|teleport| include?(teleport)}
    @data
  end
  #--------------------------------------------------------------------------
  # Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      text = item.discovered ? item.name : CSCA::TELE::UNDISCOVERED_TEXT
      change_color(normal_color, enable?(item))
      draw_text(rect.x, rect.y, contents.width, line_height, text)
      change_color(normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # Image Window Writer Method
  #--------------------------------------------------------------------------
  def image_window=(image_window)
    @image_window = image_window
  end
  #--------------------------------------------------------------------------
  # Cost Window Writer Method
  #--------------------------------------------------------------------------
  def cost_window=(cost_window)
    @cost_window = cost_window
  end
  #--------------------------------------------------------------------------
  # Update Teleport Info/Image/Cost Window
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_item(item)
    @cost_window.set_item(item) if @cost_window
    @image_window.set_item(item) if @image_window
  end
end
#==============================================================================
# ** CSCA_Window_TeleportCost
#------------------------------------------------------------------------------
#  Displays currently selected teleport cost.
#==============================================================================
class CSCA_Window_TeleportCost < Window_Base
  #--------------------------------------------------------------------------
  # Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, w, h)
    super(x, y, w, h)
  end
  #--------------------------------------------------------------------------
  # Set Item
  #--------------------------------------------------------------------------
  def set_item(item)
    contents.clear
    @teleport = item
    draw_title
    if !@teleport.discovered || (@teleport.mp == 0 && @teleport.item.nil?)
      draw_no_cost
    elsif @teleport.mp > 0 && !@teleport.item.nil?
      draw_both_cost
    elsif @teleport.mp > 0 && @teleport.item.nil?
      draw_mp_cost
    else
      draw_item_cost
    end
  end
  #--------------------------------------------------------------------------
  # Draw title text
  #--------------------------------------------------------------------------
  def draw_title
    contents.font.bold = true
    change_color(system_color)
    draw_text(0, 0, contents.width, line_height, "Cost:", 1)
    change_color(normal_color)
    contents.font.bold = false
  end
  #--------------------------------------------------------------------------
  # Draw free/undiscovered cost.
  #--------------------------------------------------------------------------
  def draw_no_cost
    text = @teleport.discovered ? CSCA::TELE::FREE : "Unknown"
    draw_text(0, line_height, contents.width, line_height, text, 1)
  end
  #--------------------------------------------------------------------------
  # Draw MP cost
  #--------------------------------------------------------------------------
  def draw_mp_cost
    text = @teleport.mp.to_s + " " + Vocab::mp
    draw_text(0, line_height, contents.width, line_height, text, 1)
  end
  #--------------------------------------------------------------------------
  # Draw item cost
  #--------------------------------------------------------------------------
  def draw_item_cost
    item = $data_items[@teleport.item]
    draw_item_name(item, 0, line_height, true, contents.width)
  end
  #--------------------------------------------------------------------------
  # Draw item and mp cost
  #--------------------------------------------------------------------------
  def draw_both_cost
    text = @teleport.mp.to_s + " " + Vocab::mp
    draw_text(0, line_height*2, contents.width, line_height, text, 1)
    draw_item_cost
  end
end
#==============================================================================
# ** CSCA_Window_TeleportImage
#------------------------------------------------------------------------------
#  Displays currently selected teleport image.
#==============================================================================
class CSCA_Window_TeleportImage < Window_Base
  #--------------------------------------------------------------------------
  # Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, w, h)
    super(x, y, w, h)
  end
  #--------------------------------------------------------------------------
  # Set Item
  #--------------------------------------------------------------------------
  def set_item(teleport)
    contents.clear
    bitmap = Bitmap.new(CSCA::TELE::FOLDER + teleport.image)
    target = Rect.new(0, 0, contents.width, contents.height)
    contents.stretch_blt(target, bitmap, bitmap.rect)
  end
end
#==============================================================================
# ** CSCA_Window_TeleportDescription
#------------------------------------------------------------------------------
#  Displays currently selected teleport description text.
#==============================================================================
class CSCA_Window_TeleportDescription < Window_Base
  #--------------------------------------------------------------------------
  # Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, w, h)
    super(x, y, w, h)
  end
  #--------------------------------------------------------------------------
  # Set Item
  #--------------------------------------------------------------------------
  def set_item(teleport)
    contents.clear
    y = 0
    teleport.description.each do |line|
      draw_text(0, y, contents.width, line_height, line, 1)
      y += line_height
    end
  end
end
#==============================================================================
# ** Scene_ItemBase
#------------------------------------------------------------------------------
# Special handling for teleport items/skills.
#Aliases: use_item
#==============================================================================
class Scene_ItemBase < Scene_MenuBase
  #--------------------------------------------------------------------------
  # Alias Method; Use Item
  #--------------------------------------------------------------------------
  alias :csca_tp_use_item :use_item
  def use_item
    csca_tp_use_item
    check_teleport
  end
  #--------------------------------------------------------------------------
  # Handling if item/skill has teleports
  #--------------------------------------------------------------------------
  def check_teleport
    if item.csca_has_teleport?
      actor = item.is_a?(RPG::Skill) ? user : $game_party.leader
      SceneManager.call(CSCA_Scene_Teleport)
      SceneManager.scene.prepare(item.csca_teleport_type, actor)
    end
  end
end
#==============================================================================
# ** CSCA_Window_Toast
#------------------------------------------------------------------------------
# Show toasts for teleport discovery.
#==============================================================================
class CSCA_Window_Toast < Window_Base
  #--------------------------------------------------------------------------
  # Alias Method; refresh
  #--------------------------------------------------------------------------
  alias :csca_tp_refresh :refresh
  def refresh(params)
    csca_tp_refresh(params)
    if params[0] == :tele_disc
      teleport = params[1]
      contents.font.bold = true
      change_color(system_color)
      draw_text(0, 0, contents.width, line_height, CSCA::TELE::DISCOVER_TEXT, 1)
      change_color(normal_color)
      contents.font.bold = false
      draw_text(0, line_height, contents.width, line_height, teleport.name, 1)
    end
  end
end