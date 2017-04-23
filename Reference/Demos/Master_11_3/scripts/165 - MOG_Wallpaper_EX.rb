#==============================================================================
# +++ MOG - Wallpaper EX (V2.1) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# - Adiciona um papel de parede e adiciona alguns efeitos animados.
#==============================================================================
# Para mudar de papel de parede no meio do jogo basta usar o
# código abaixo.
#
# wallpaper(file_name, scroll_x, scroll_y)
#
# EX
#
# wallpaper("Wallpaper01",3,0)
#
#==============================================================================
# Use o código abaixo para mudar a imagem da particula.
#
# particle_name(file_name)
#
#==============================================================================
# Para mudar a opacidade da janela use o código abaixo.
# 
# window_opacity(opacity)
#
# EX
#
# window_opacity(200)
#
#==============================================================================
# Serão necessários os seguintes arquivos na pasta GRAPHICS/SYSTEM.
# 
# Menu_Particles.png
# Wallpaper.jpg
#
#==============================================================================
module MOG_WALLPAPER_EX
  #Ativar Particulas animadas.
  PARTICLES = true
  #Numero de particulas.
  NUMBER_OF_PARTICLES = 10
  #Deslizar a imagem de fundo.
  BACKGROUND_SCROLL_SPEED = [0,0]
  #Definição da opacidade das janelas.
  WINDOW_OPACITY = 32
  #Definição das Scenes que terão o sistema ativado.
  WALLPAPER_SCENES = ["Scene_Menu","Scene_Item","Scene_Skill",
      "Scene_Equip","Scene_Status","Scene_Save","Scene_Load",
      "Scene_Name","Scene_End","Scene_Shop"]
end

$imported = {} if $imported.nil?
$imported[:mog_wallpaper_ex] = true

#==============================================================================
# ■ Game_System
#==============================================================================
class Game_System
  
  attr_accessor :wallpaper
  attr_accessor :wallpaper_scroll
  attr_accessor :wallpaper_window_opacity
  attr_accessor :menu_particle
  attr_accessor :menu_transition
  
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------  
  alias mog_wallpaper_initialize initialize
  def initialize
      mog_wallpaper_initialize
      @wallpaper = "Wallpaper"    
      @menu_particle = ["Menu_Particles",0,3,0,1]
      @wallpaper_scroll = MOG_WALLPAPER_EX::BACKGROUND_SCROLL_SPEED
      @wallpaper_window_opacity  = MOG_WALLPAPER_EX::WINDOW_OPACITY
      @menu_transition = ["",10]
  end
  
end  

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● Cursor Name
  #--------------------------------------------------------------------------    
  def wallpaper(file_name = "",x = 0,y = 0)
      $game_system.wallpaper = file_name.to_s
      $game_system.wallpaper_scroll = [x,y]
  end
  
  #--------------------------------------------------------------------------
  # ● Window Opacity
  #--------------------------------------------------------------------------    
  def window_opacity(opact)
      $game_system.wallpaper_window_opacity = opact
  end  
  
  #--------------------------------------------------------------------------
  # ● Menu Particle
  #--------------------------------------------------------------------------    
  def menu_particle(file_name = "",x = 0,y = 3,angle = 0,blend = 1)
      y = 3 if x == 0 and y == 0
      $game_system.menu_particle = [file_name,x,y,angle,blend]
  end    
  
  #--------------------------------------------------------------------------
  # ● Menu transition
  #--------------------------------------------------------------------------    
  def menu_transition(file_name,time = 10)
      $game_system.menu_transition = [file_name.to_s,time]
  end     
  
end

#==============================================================================
# ■ Menu Particles
#==============================================================================
class Menu_Particles < Sprite
  
 #--------------------------------------------------------------------------
 # ● Initialize
 #--------------------------------------------------------------------------             
  def initialize(viewport = nil)
      super(viewport)
      self.bitmap = Cache.system($game_system.menu_particle[0].to_s)
      @cw = self.bitmap.width ; @ch = self.bitmap.height
      @limit1 = [@cw + (@cw / 2),@ch + (@ch / 2)]
      @limit2 = [Graphics.width + @limit1[0], Graphics.height + @limit1[1]]
      self.z = 5 ; reset_setting(true)
  end  
  
 #--------------------------------------------------------------------------
 # ● Reset Setting
 #--------------------------------------------------------------------------               
  def reset_setting(start)
      zoom = (50 + rand(75)) / 100.1
      self.zoom_x = zoom ; self.zoom_y = zoom ; self.x = rand(Graphics.width)
      if start
         self.y = rand(Graphics.height + self.bitmap.height)
      else
         self.y = Graphics.height + rand(32 + self.bitmap.height)
      end        
      self.opacity = 0
      self.blend_type = $game_system.menu_particle[4]
      $game_system.menu_particle[0]
      if $game_system.menu_particle[1] != 0
         @speed_x = [[rand($game_system.menu_particle[1]), 20].min, 1].max
      else
         @speed_x = 0
      end  
      if $game_system.menu_particle[2] != 0
         @speed_y = [[rand($game_system.menu_particle[2]), 20].min, 1].max
      else
         @speed_y = 0
      end  
      if $game_system.menu_particle[3] != 0
         @speed_a = [[rand($game_system.menu_particle[3]), 20].min, 1].max
      else
         @speed_a = 0
      end
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose
 #--------------------------------------------------------------------------               
  def dispose
      super
      self.bitmap.dispose
  end  
  
 #--------------------------------------------------------------------------
 # ● Update
 #--------------------------------------------------------------------------               
  def update
      super
      self.x += @speed_x ;  self.y -= @speed_y ; self.angle += @speed_a      
      self.opacity += 5 ; reset_setting(false) if can_reset?
  end  
  
 #--------------------------------------------------------------------------
 # ● Can Reset?
 #--------------------------------------------------------------------------               
  def can_reset?
      return true if !self.x.between?(-@limit1[0],@limit2[0])
      return true if !self.y.between?(-@limit1[1],@limit2[1])
      return false
  end
  
end

#==============================================================================
# ● Scene MenuBase
#==============================================================================
class Scene_MenuBase < Scene_Base
  include MOG_WALLPAPER_EX 
  
  #--------------------------------------------------------------------------
  # ● Transition Name
  #--------------------------------------------------------------------------
  def transition_name
      if $game_system.menu_transition[0] == nil or
         $game_system.menu_transition[0] == ""
         return ""
      end   
      return "Graphics/System/" + $game_system.menu_transition[0].to_s    
  end
  
  #--------------------------------------------------------------------------
  # ● Perform Transition
  #--------------------------------------------------------------------------
  def perform_transition
      Graphics.transition(transition_speed,transition_name)
  end
  #--------------------------------------------------------------------------
  # ● Transition Speed
  #--------------------------------------------------------------------------
  def transition_speed
      return $game_system.menu_transition[1]
  end  
  
  #--------------------------------------------------------------------------
  # ● Can Create Wallpaper
  #--------------------------------------------------------------------------                  
  def can_create_wallpaper?
      return false if !WALLPAPER_SCENES.include?(SceneManager.scene.class.to_s)
      return true
  end   
  
  #--------------------------------------------------------------------------
  # ● Pos Start
  #--------------------------------------------------------------------------            
  alias mog_wallpaper_ex_post_start post_start
  def post_start
      set_window_opacity if can_create_wallpaper?
      mog_wallpaper_ex_post_start      
  end
  
  #--------------------------------------------------------------------------
  # ● Set Window OPACITY
  #--------------------------------------------------------------------------            
  def set_window_opacity
      instance_variables.each do |varname|
          ivar = instance_variable_get(varname)
          if ivar != nil and ivar.is_a?(Window) 
             ivar.opacity = $game_system.wallpaper_window_opacity if !ivar.disposed?
          end
      end
  end    
  
  #--------------------------------------------------------------------------
  # ● Create Background
  #--------------------------------------------------------------------------                  
  alias mog_wallpaper_ex_create_background create_background
  def create_background
      mog_wallpaper_ex_create_background
     (create_wallpaper ; create_particles) if can_create_wallpaper?
  end
 
  #--------------------------------------------------------------------------
  # ● Create Wallpaper
  #--------------------------------------------------------------------------                  
  def create_wallpaper
      return if @wallpaper != nil
      @wallpaper_scroll_speed = 0 ; @wallpaper = Plane.new
      @wallpaper.bitmap = Cache.system($game_system.wallpaper) rescue nil
      @wallpaper.z = @background_sprite.z + 1   
  end
    
  #--------------------------------------------------------------------------
  # ● Create Particles
  #--------------------------------------------------------------------------  
  def create_particles
      return unless PARTICLES
      dispose_menu_particles
      range = [Graphics.width + 32, Graphics.height + 32]
      @particle_viewport = Viewport.new(-32, -32, range[0], range[1])
      @particle_viewport.z = 5
      @particle_bitmap = []
      for i in 0...NUMBER_OF_PARTICLES
          @particle_bitmap.push(Menu_Particles.new(@particle_viewport))
      end  
  end    
  
  #--------------------------------------------------------------------------
  # ● Dispose Background
  #--------------------------------------------------------------------------  
  alias mog_wallpaper_ex_dispose_background dispose_background
  def dispose_background
      dispose_menu_particles ; dispose_wallpaper
      mog_wallpaper_ex_dispose_background
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Wallpaper
  #--------------------------------------------------------------------------  
  def dispose_wallpaper
      return if @wallpaper == nil
      @wallpaper.dispose ; @wallpaper = nil
  end
  
 #--------------------------------------------------------------------------
 # ● Dispose Light
 #--------------------------------------------------------------------------              
  def dispose_menu_particles
      return if !PARTICLES
      return if @particle_bitmap == nil
      @particle_bitmap.each {|sprite| sprite.dispose} 
      @particle_viewport.dispose ; @particle_bitmap = nil
  end   
  
 #--------------------------------------------------------------------------
 # ● Update Basic
 #--------------------------------------------------------------------------              
  alias mog_wallpaper_ex_update_basic update_basic
  def update_basic
      mog_wallpaper_ex_update_basic
      update_wallpaper_ex
  end
  
 #--------------------------------------------------------------------------
 # ● Update Wallpaper EX
 #--------------------------------------------------------------------------              
  def update_wallpaper_ex
      update_wallpaper ; update_particle
  end
  
  #--------------------------------------------------------------------------
  # ● Update Background
  #--------------------------------------------------------------------------    
  def update_wallpaper
      return if @wallpaper == nil
      @wallpaper_scroll_speed += 1
      return if @wallpaper_scroll_speed < 2
      @wallpaper_scroll_speed = 0
      @wallpaper.ox += $game_system.wallpaper_scroll[0]
      @wallpaper.oy += $game_system.wallpaper_scroll[1] 
  end
  
 #--------------------------------------------------------------------------
 # ● Update Particle
 #--------------------------------------------------------------------------              
 def update_particle
     return if @particle_bitmap == nil
     @particle_bitmap.each {|sprite| sprite.update }
 end    
  
end
