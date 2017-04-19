#==============================================================================
# +++ MOG - Battle Command EX (v2.1) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# Sistema de comandos animados com grande possibilidade de customização.
#==============================================================================

#==============================================================================
# ■ UTILIZAÇÃO
#==============================================================================
# Grave as imagens na pasta Graphics/Huds/Battle/
#==============================================================================

#==============================================================================
# ● Layout padrão
#==============================================================================
# Basta ter uma imagem com o nome:
#
# Layout_Command.png
#
#==============================================================================
# ● Layout Personalizado.
#==============================================================================
# Para ativar o layout baseado na ID do personagem nomeie as imagens da 
# seguinte forma:
#
# Layout_Command + ACTOR_ID.png
#
#==============================================================================

#==============================================================================
# ● Ícones personalizados
#==============================================================================
# Para ativar os ícones personalizados, nomeie os imagens da seguinte forma:
#
# Com_ + COMMAND_NAME.png
# 
# (EX - Com_Attack.png   / Com_Magic.png / Com_Guard.png / ...)
#
#==============================================================================

#==============================================================================
# ● Cursor de Commando
#==============================================================================
# Basta ter uma imagem com o nome:
#
# Cursor_Com.png
#
#==============================================================================

#==============================================================================
# Atualização desta versão.
#==============================================================================
# v2.1 - Correção do bug de não ativar o movimento do cursor em algumas opções.
#      - Correção da posição do comando após adicionar um personagem na batalha.
# v2.0 - Adição da função scroll.
#      - Adição de novas opções na função ring command.
#      - Adição do sprite do cursor.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_battle_command_ex] = true

module MOG_BATTLE_COMMAND_EX
  #============================================================================
  # Definição do tipo de commando
  #============================================================================
  # 0 - Default + Ícones
  # 1 - Comando na horizontal.
  # 2 - Comando de ícones na vertical.
  # 3 - Comando de ícones na horizontal.
  # 4 - Ring Command.
  #============================================================================
  COMMAND_TYPE = 0
  #============================================================================
  # Definição da posição do comando
  #============================================================================
  DEFAULT_COMMAND_POSITION = [0,0]
  #============================================================================
  # Definição da posição do comando específico baseado na posição ID do battler.
  #============================================================================
  # 
  # FIXED_COMMAND_POSITION = [[50,50],[100,100],[200,200],[300,300]]
  #
  #============================================================================
  FIXED_COMMAND_POSITION = []
  #============================================================================
  # Definição da posição Z do comando.
  #============================================================================
  COMMAND_Z = 203
  #============================================================================
  # Definição da posição do layout.
  #============================================================================
  LAYOUT_POSITION = [0,0]
  #============================================================================
  # Definição da posição do nome do comando.
  #============================================================================  
  COMMANND_NAME_POSITION = [0,0]  
  #============================================================================
  # Definição do tamanho da circunferência do comando de ícones
  #============================================================================
  RING_COMMAND_SIZE = 60
  #============================================================================
  # Definição da circunferência do comando
  #============================================================================
  RING_COMMAND_RATE = 360
  #============================================================================
  # Ativar animação de movimento.
  #============================================================================
  RING_COMMAND_MOVEMENT = true  
  #============================================================================
  # Definição da opacidade da janela de comandos.
  #============================================================================
  WINDOWSKIN_OPACITY = 0
  #============================================================================
  # Definição do espaço entre os ícones
  #============================================================================
  ICONS_SPACE = 5
  #============================================================================
  # Ativa posição no modo Battle HUD EX (Necessário ter o script do Battle Hud).
  #============================================================================  
  BATTLE_HUD_EX_POSITION = true
  #============================================================================
  # Ativar a janela de Face (Exceto no modo 0).
  #============================================================================  
  WINDOW_FACE = true
  #============================================================================
  # Ativar o nome do comando.
  #============================================================================  
  COMMAND_NAME = true
  #============================================================================
  # Ativar o efeito de zoom.
  #============================================================================  
  ZOOM_EFFECT = false  
  #============================================================================
  # Ativar a animação do zoom em loop.
  #============================================================================  
  LOOP_ZOOM_ANIMATION = true
  #============================================================================
  # Ativar a animação do slide no comando selecionado.
  #============================================================================  
  SLIDE_ANIMATION = true
  #============================================================================
  # Ativar a animação do slide no comando baseado na posição X e Y.
  #============================================================================  
  SLIDE_EX_ANIMATION = false
  #============================================================================
  # Ponto inicial do Slide.
  #============================================================================
  SLIDE_EX_ANIMATION_RANGE = [100,150]  
  #============================================================================
  # Definição do ângulo do sprite do nome.
  #============================================================================  
  COMMAND_NAME_ANGLE = 0
  #============================================================================
  # Definição do ângulo do sprite dos ícones.
  #============================================================================  
  COMMAND_ICON_ANGLE = 0
  #============================================================================
  # Definição da Index dos ícones e seus respectivos comandos.
  #============================================================================  
  COMMAND_ICON_INDEX = {
  "Special" => 134,
  "Magic" => 136,
  "Guard" => 160,
  "Items" => 192,
  "Overdrive" => 143
  }
  #============================================================================
  # Ativar ícones personalizados.
  #============================================================================  
  CUSTOM_ICONS_COMMANDS = false
  #============================================================================
  # Ativar scroll nos comandos na vertical.
  #============================================================================  
  SCROLL_ROW = false
  #============================================================================
  # Definição do limite de linhas
  #============================================================================  
  ROW_MAX = 4  
  #============================================================================
  # Ativar o sprite de cursor (Somente para o modo 2 ou 3)
  #============================================================================  
  SPRITE_CURSOR_CM = false
  #============================================================================
  # Definição da posição do cursor.
  #============================================================================  
  SPRITE_CURSOR_CM_POSITION = [-60,-10]
  #============================================================================
  # Definição da posição z do cursor
  #============================================================================  
  SPRITE_CURSOR_CM_Z = 5
  #============================================================================
  # Ativar animação de Slide no cursor
  #============================================================================    
  SPRITE_CURSOR_CM_SLIDE_ANIMATION = false
  #============================================================================
  # Ativar o efeito de piscar
  #============================================================================      
  SPRITE_CURSOR_CM_BLINK_EFFECT = false
  #============================================================================
  # Ativar a animação de movimento lateral.
  #============================================================================      
  SPRITE_CURSOR_CM_SIDE_ANIMATION = true
end

#==============================================================================
# ■ Cache
#==============================================================================
module Cache

  #--------------------------------------------------------------------------
  # ● Hud
  #--------------------------------------------------------------------------
  def self.battle_hud(filename)
      load_bitmap("Graphics/Huds/Battle/", filename)
  end

end

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  
  attr_accessor :bc_position
  attr_accessor :battle_end
  attr_accessor :refresh_battle_command
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_battle_command_initialize initialize
  def initialize
      @bc_position = [0,0] ; @battle_end = false ; @refresh_battle_command = false
      mog_battle_command_initialize
  end
  
end

#==============================================================================
# ** Game Interpreter
#==============================================================================
class Game_Interpreter
  
 #--------------------------------------------------------------------------
 # ● Command_129
 #--------------------------------------------------------------------------
 alias mog_bcex_command_129 command_129
 def command_129
     mog_bcex_command_129 
     $game_temp.refresh_battle_command = true if SceneManager.scene_is?(Scene_Battle)
 end
 
end 
 
#==============================================================================
# ** Game Party
#==============================================================================
class Game_Party < Game_Unit
    
 #--------------------------------------------------------------------------
 # * Swap Order
 #--------------------------------------------------------------------------
 alias mog_bcommand_ex_swap_order swap_order
 def swap_order(index1, index2)
      $game_temp.refresh_battle_command = true if SceneManager.scene_is?(Scene_Battle)
      mog_bcommand_ex_swap_order(index1, index2)
 end  
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  if [1,2,3,4].include?(MOG_BATTLE_COMMAND_EX::COMMAND_TYPE)
  #--------------------------------------------------------------------------
  # ● Create Actor Command Window
  #--------------------------------------------------------------------------
  alias mog_battle_command_create_actor_command_window create_actor_command_window
  def create_actor_command_window
      mog_battle_command_create_actor_command_window
      @actor_command_window.viewport = nil
      @actor_command_window.x = 0
      @actor_command_window.y = Graphics.height - (@status_window.height + @actor_command_window.height)
      $game_temp.bc_position = [@actor_command_window.x, @actor_command_window.y]
      create_window_actor_face if MOG_BATTLE_COMMAND_EX::WINDOW_FACE
  end
  else
  #--------------------------------------------------------------------------
  # ● Create Actor Command Window
  #--------------------------------------------------------------------------
    alias mog_battle_command_2_create_actor_command_window create_actor_command_window
    def create_actor_command_window
        mog_battle_command_2_create_actor_command_window
        $game_temp.bc_position = [@actor_command_window.x, @actor_command_window.y]
    end  
  end

  #--------------------------------------------------------------------------
  # ● Create Window Actor Face
  #--------------------------------------------------------------------------
  def create_window_actor_face
      return if $imported[:mog_battle_hud_ex]
      cw = 128 ; ch = @status_window.height 
      cx = Graphics.width ; cy = 0
      @window_actor_face = Window_BattleActor_Face.new(cx,cy,cw,ch)
      @window_actor_face.z = @status_window.z
      @window_actor_face.viewport = @status_window.viewport
      @window_actor_face.visible = @actor_command_window.visible
  end
  
  #--------------------------------------------------------------------------
  # ● Terminate
  #--------------------------------------------------------------------------
  alias mog_battle_command_terminate terminate
  def terminate
      @window_actor_face.dispose if @window_actor_face != nil
      mog_battle_command_terminate
  end
  
  #--------------------------------------------------------------------------
  # ● Turn Start
  #--------------------------------------------------------------------------
  alias mog_battle_command_turn_start turn_start
  def turn_start
      mog_battle_command_turn_start
      @window_actor_face.visible = false if @window_actor_face != nil
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Base
  #--------------------------------------------------------------------------
  alias mog_battle_command_update_basic update_basic
  def update_basic
      mog_battle_command_update_basic
      @window_actor_face.visible = window_actor_face_visible? if @window_actor_face != nil
  end
  
  #--------------------------------------------------------------------------
  # ● Window Actor Face Visible?
  #--------------------------------------------------------------------------
  def window_actor_face_visible?
      return false if $imported[:mog_battle_hud_ex]
      return false if $game_message.visible
      return false if BattleManager.actor == nil
      return false if $game_temp.battle_end
      return true 
  end
  
  if $imported[:mog_atb_system]   
  #--------------------------------------------------------------------------
  # ● Need Hide Window
  #--------------------------------------------------------------------------
  alias mog_battle_command_need_hide_window? need_hide_window?
  def need_hide_window?(ivar,actor_window)
      return false if ivar.is_a?(Window_BattleActor_Face) and actor_window
      mog_battle_command_need_hide_window?(ivar,actor_window)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Actor Command Selection
  #--------------------------------------------------------------------------
  alias mog_battle_command_execute_start_actor_command execute_start_actor_command
  def execute_start_actor_command(se)
      mog_battle_command_execute_start_actor_command(se)
      if @window_actor_face != nil and @window_actor_face.actor != BattleManager.actor
         @window_actor_face.actor = BattleManager.actor
         @window_actor_face.refresh
      end   
  end     
  else
  #--------------------------------------------------------------------------
  # ● Start Actor Command Selection
  #--------------------------------------------------------------------------
  alias mog_battle_command_start_actor_command start_actor_command_selection
  def start_actor_command_selection
      mog_battle_command_start_actor_command 
      if @window_actor_face != nil and @window_actor_face.actor != BattleManager.actor
         @window_actor_face.actor = BattleManager.actor
         @window_actor_face.refresh
      end   
  end    
  end

end

#==============================================================================
# ■ Window ActorCommand
#==============================================================================
class Window_ActorCommand < Window_Command
  
  include MOG_BATTLE_COMMAND_EX

  if COMMAND_TYPE == 0
  #--------------------------------------------------------------------------
  # ● Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
      change_color(normal_color, command_enabled?(index))
      if Vocab::attack == command_name(index)
         icon_index = @actor.equips[0].icon_index rescue nil
         icon_index = -1 if icon_index == nil
         draw_icon(icon_index , 0, index * line_height, command_enabled?(index))
      else
         icon_index = COMMAND_ICON_INDEX[command_name(index)] rescue nil
         icon_index = -1 if icon_index == nil
         bitmap = Cache.system("Iconset")
         rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
         contents.blt(0, index * line_height, bitmap, rect, command_enabled?(index) ? 255 : translucent_alpha)    
      end 
      draw_text(24, index * line_height,self.width - 42,line_height, command_name(index), alignment)
  end
  
  elsif COMMAND_TYPE == 1  
  #--------------------------------------------------------------------------
  # ● Window Width
  #--------------------------------------------------------------------------
  def window_width
      return Graphics.width
  end

  #--------------------------------------------------------------------------
  # ● Visible Line Number
  #--------------------------------------------------------------------------
  def visible_line_number
      return 1
  end
  
  #--------------------------------------------------------------------------
  # ● Col Max
  #--------------------------------------------------------------------------
  def col_max
      return 4
  end
  
  #--------------------------------------------------------------------------
  # ● Spacing
  #--------------------------------------------------------------------------
  def spacing
      return 8
  end
  
  #--------------------------------------------------------------------------
  # ● Contents Width
  #--------------------------------------------------------------------------
  def contents_width
      (item_width + spacing) * item_max - spacing
  end
  
  #--------------------------------------------------------------------------
  # ● Contents Height
  #--------------------------------------------------------------------------
  def contents_height
      item_height
  end
  
  #--------------------------------------------------------------------------
  # ● Get Leading Digits
  #--------------------------------------------------------------------------
  def top_col
      ox / (item_width + spacing)
  end
  
  #--------------------------------------------------------------------------
  # ● Tol Col
  #--------------------------------------------------------------------------
  def top_col=(col)
      col = 0 if col < 0
      col = col_max - 1 if col > col_max - 1
      self.ox = col * (item_width + spacing)
  end
  
  #--------------------------------------------------------------------------
  # ● Get Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col
      top_col + col_max - 1
  end
  
  #--------------------------------------------------------------------------
  # ● Botton Col
  #--------------------------------------------------------------------------
  def bottom_col=(col)
      self.top_col = col - (col_max - 1)
  end
 
  #--------------------------------------------------------------------------
  # ● Ensure Cursor Visible
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
      self.top_col = index if index < top_col
      self.bottom_col = index if index > bottom_col
  end
  
  #--------------------------------------------------------------------------
  # ● Item Rect
  #--------------------------------------------------------------------------
  def item_rect(index)
      rect = super
      rect.x = index * (item_width + spacing)
      rect.y = 0
      rect
  end

  #--------------------------------------------------------------------------
  # ● Alignment
  #--------------------------------------------------------------------------
  def alignment
      return 1
  end

  #--------------------------------------------------------------------------
  # ● Cursor_Down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  
  #--------------------------------------------------------------------------
  # ● Move Cursor Up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  
  #--------------------------------------------------------------------------
  # ● Cursor Page Down
  #--------------------------------------------------------------------------
  def cursor_pagedown
  end
  
  #--------------------------------------------------------------------------
  # ● Cursor Pageup
  #--------------------------------------------------------------------------
  def cursor_pageup
  end  
    
  #--------------------------------------------------------------------------
  # ● Space W
  #--------------------------------------------------------------------------
  def space_w
      (item_width + spacing)
  end
  
  #--------------------------------------------------------------------------
  # ● Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
      change_color(normal_color, command_enabled?(index))
      if Vocab::attack == command_name(index)
         icon_index = @actor.equips[0].icon_index rescue nil
         icon_index = -1 if icon_index == nil
         draw_icon(icon_index , 0, index * line_height, command_enabled?(index))
      else
         icon_index = COMMAND_ICON_INDEX[command_name(index)] rescue nil
         icon_index = -1 if icon_index == nil
         bitmap = Cache.system("Iconset")
         rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
         contents.blt(space_w * index, 0, bitmap, rect, command_enabled?(index) ? 255 : translucent_alpha)    
      end 
      draw_text(26 + (space_w * index), 0, space_w ,line_height, command_name(index), 0)
  end  
  end
  
end

#==============================================================================
# ■ Window ActorCommand
#==============================================================================
class Window_ActorCommand < Window_Command 
  attr_reader :list
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_bc_ac_initialize initialize
  def initialize      
      mog_bc_ac_initialize
      bc_setup
  end
  
  #--------------------------------------------------------------------------
  # ● Bc Setup
  #--------------------------------------------------------------------------
  def bc_setup
      self.z = COMMAND_Z
      status = Window_BattleStatus.new
      @stwh = [status.window_width, status.window_height]
      status.dispose
      @nxy = [0,0] ;  @bex = [0,0] ; @c_nxy = [0,0]
      @roll_range = RING_COMMAND_SIZE
      @comr = 0
      cache_bc_sprites ; create_layout ; create_cursor_cm
  end
  
  #--------------------------------------------------------------------------
  # ● Cache BC Sprites
  #--------------------------------------------------------------------------
  def cache_bc_sprites
      @bc_images = [] ; @s_row_max = ROW_MAX - 1
      for actor in $game_party.battle_members
      @bc_images[actor.id] = Cache.battle_hud("Layout_Command" + actor.id.to_s) rescue nil
      if @bc_images[actor.id] != nil
         @bc_images[actor.id] = nil if @bc_images[actor.id].width == 32 and @bc_images[actor.id].height == 32
      end
      @bc_images[actor.id] = Cache.battle_hud("Layout_Command") rescue nil if @bc_images[actor.id] == nil      
      @bc_images[actor.id] = Bitmap.new(32,32) if @bc_images[actor.id] == nil
      end
      if CUSTOM_ICONS_COMMANDS
      for actor in $game_party.battle_members
          @actor = actor ; make_command_list
          for l in @list ; Cache.battle_hud("Com_" + l[:name].to_s) ; end
          @list.clear ; @actor = nil
      end
      end
  end

  #--------------------------------------------------------------------------
  # ● Create Layout
  #--------------------------------------------------------------------------  
  def create_layout
      @layout_bt_org = [0,0]
      @layout_bt = Sprite.new ; @layout_bt.z = self.z - 2 ; refresh_layout_bt
  end

  #--------------------------------------------------------------------------
  # ● Create Cursor CM
  #--------------------------------------------------------------------------  
  def create_cursor_cm
      return if !SPRITE_CURSOR_CM
      @cursor_cm_bdata = [0,0,0] ; @mxc = [0,0,0]
      @cursor_cm = Sprite.new
      @cursor_cm.bitmap = Cache.battle_hud("Cursor_Com")
      @cursor_cm.ox = @cursor_cm.bitmap.width / 2
      @cursor_cm.oy = @cursor_cm.bitmap.height / 2
      @cursor_cm.z = self.z + SPRITE_CURSOR_CM_Z
      @cursor_cm.visible = false      
      @c_org = [SPRITE_CURSOR_CM_POSITION[0],SPRITE_CURSOR_CM_POSITION[1]]
  end
  
  #--------------------------------------------------------------------------
  # ● Update Cursor CM
  #--------------------------------------------------------------------------  
  def update_cursor_cm
      return if @cursor_cm == nil      
      @cursor_cm.visible = self.visible
      return if !@cursor_cm.visible
      if SPRITE_CURSOR_CM_SLIDE_ANIMATION
         execute_move_rg(@cursor_cm,0,@cursor_cm.x,@c_nxy[0] + @c_org[0] + @mxc[1])
         execute_move_rg(@cursor_cm,1,@cursor_cm.y,@c_nxy[1] + @c_org[1])
      else  
         @cursor_cm.x = @c_nxy[0] + @c_org[0] + @mxc[1] ; @cursor_cm.y = @c_nxy[1]
      end
      update_cursor_cm_blink
      update_cursor_cm_side_animation
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Cursor CM Blink
  #--------------------------------------------------------------------------  
  def update_cursor_cm_blink
      return if !SPRITE_CURSOR_CM_BLINK_EFFECT
      @cursor_cm_bdata[1] += 1
      case @cursor_cm_bdata[1]
         when 0..30 ;  @cursor_cm_bdata[0] += 4
         when 31..60 ; @cursor_cm_bdata[0] -= 4
         else
           @cursor_cm_bdata[1] = 0 ; @cursor_cm_bdata[0] = 0
      end
      @cursor_cm.opacity = 145 + @cursor_cm_bdata[0]
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Animation S
  #--------------------------------------------------------------------------      
  def update_cursor_cm_side_animation
      return if !SPRITE_CURSOR_CM_SIDE_ANIMATION
      @mxc[2] += 1
      return if @mxc[2] < 4
      @mxc[2] = 0 ; @mxc[0] += 1
      case @mxc[0]
         when 1..7;  @mxc[1] += 1            
         when 8..14; @mxc[1] -= 1
         else ; @mxc[0] = 0 ; @mxc[1] = 0
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Dispose Cursor CM
  #--------------------------------------------------------------------------  
  def dispose_cursor_cm
      return if @cursor_cm == nil
      @cursor_cm.bitmap.dispose
      @cursor_cm.dispose      
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh Layout BT
  #--------------------------------------------------------------------------  
  def refresh_layout_bt
      return if @layout_bt == nil
      @layout_bt.viewport = self.viewport
      self.opacity = WINDOWSKIN_OPACITY if COMMAND_TYPE < 2
      if @actor != nil and @bc_images[@actor.id] != nil
         @layout_bt.bitmap = @bc_images[@actor.id]
      else   
         @layout_bt.bitmap = @bc_images[0]
      end  
      if @sprite_commands == nil
         @layout_bt.x = self.x + LAYOUT_POSITION[0] 
         @layout_bt.y = self.y + LAYOUT_POSITION[1]
      end
      @layout_bt_org = [@layout_bt.x,@layout_bt.y]
  end
  
  #--------------------------------------------------------------------------
  # ● Process Cursor Move Left Right
  #--------------------------------------------------------------------------
  def process_cursor_move_left_right
      return unless cursor_movable?
      last_index = @index
      cursor_down (Input.trigger?(:RIGHT))  if Input.repeat?(:RIGHT)
      cursor_up   (Input.trigger?(:LEFT))    if Input.repeat?(:LEFT)
      Sound.play_cursor if @index != last_index
  end  

  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  alias mog_bc_dispose dispose
  def dispose
      mog_bc_dispose
      dispose_battle_command_ex
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Battle Command EX
  #--------------------------------------------------------------------------  
  def dispose_battle_command_ex
      dispose_sprite_command ; dispose_layout_bc ; dispose_cursor_cm
      @bc_images.each {|sprite| sprite.dispose if sprite != nil }
  end
    
  #--------------------------------------------------------------------------
  # ● Dispose Layout BC
  #--------------------------------------------------------------------------  
  def dispose_layout_bc
      return if @layout_bt == nil
      @layout_bt.bitmap.dispose if @layout_bt.bitmap != nil
      @layout_bt.dispose
  end
     
  #--------------------------------------------------------------------------
  # ● Dispose Sprite Command
  #--------------------------------------------------------------------------
  def dispose_sprite_command      
      return if @sprite_commands == nil
      @sprite_commands.each {|sprite| sprite.bitmap.dispose if sprite != nil ; sprite.dispose }
      return if @sprite_command_name == nil
      @sprite_command_name.bitmap.dispose ; @sprite_command_name.dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
      return if @actor == nil
      if battle_hud_ex_position?
      self.viewport = nil
      @bex = [$game_temp.hud_pos[@actor.index][0] + MOG_BATTLE_HUD_EX::ACTOR_COMMAND_POSITION[0] - (self.window_width / 2),
      $game_temp.hud_pos[@actor.index][1] + MOG_BATTLE_HUD_EX::ACTOR_COMMAND_POSITION[1] - @stwh[1] ]
      end
      clear_command_list ; make_command_list ; create_contents
      contents.clear
      self.index = 0 if self.index > @list.size
      set_window_position
      dispose_sprite_command if @actor_old != @actor 
      refresh_layout_bt if @actor_old != @actor 
      @actor_old = @actor ; create_sprite_icons ; draw_all_items
      set_slide_effect
      update_sprite_battle_command   
  end
  
  #--------------------------------------------------------------------------
  # ● Set Slide Effect
  #--------------------------------------------------------------------------
  def set_slide_effect
      return if !SLIDE_EX_ANIMATION
      return if @sprite_commands == nil
      @sprite_commands.each_with_index do |sprite, index|
          sprite.x += SLIDE_EX_ANIMATION_RANGE[0] + SLIDE_EX_ANIMATION_RANGE[0] * index
          sprite.y += SLIDE_EX_ANIMATION_RANGE[1] + SLIDE_EX_ANIMATION_RANGE[1] * index
      end
  end
    
  #--------------------------------------------------------------------------
  # ● Battle Hud EX Position
  #--------------------------------------------------------------------------
  def battle_hud_ex_position?
      return false if !BATTLE_HUD_EX_POSITION
      return false if $imported[:mog_battle_hud_ex] == nil 
      return false if COMMAND_TYPE == 1  
      return true
  end    
      
  #--------------------------------------------------------------------------
  # ● Create Sprite Icons
  #--------------------------------------------------------------------------
  def create_sprite_icons
      return if ![2,3,4].include?(COMMAND_TYPE)
      @sprite_commands = [] ;  @sprite_zoom_phase = [] ; @sprite_command_org = []
      @sprite_command_cwh = []
      for index in 0...@list.size
          @sprite_commands.push(Sprite.new)
          if CUSTOM_ICONS_COMMANDS
             bitmap = Cache.battle_hud("Com_" + @list[0][:name].to_s)
             @sprite_commands[index].bitmap = Bitmap.new(bitmap.width,bitmap.height)
          else 
             @sprite_commands[index].bitmap = Bitmap.new(24,24)
          end  
          @sprite_commands[index].z = self.z - 1
          @sprite_commands[index].opacity = 255
          @sprite_commands[index].angle = COMMAND_ICON_ANGLE
          @sprite_zoom_phase[index] = 0 ; @sprite_command_org[index] = [0,0]
          @sprite_command_cwh[index] = [0,0]
          refresh_sprite_command(index)
      end
      if COMMAND_TYPE == 4
         @sprite_commands[index].x = DEFAULT_COMMAND_POSITION[0] + @nxy[0] + @bex[0]
         @sprite_commands[index].y = DEFAULT_COMMAND_POSITION[1] + @nxy[1] + @bex[1]
         @layout_bt.ox = @layout_bt.bitmap.width / 2
         @layout_bt.oy = @layout_bt.bitmap.height / 2
      end        
      create_sprite_command_name
      @layout_bt.x = @sprite_command_org[0][0] + LAYOUT_POSITION[0]
      @layout_bt.y = @sprite_command_org[0][1] + LAYOUT_POSITION[1] 
      @layout_bt_org = [@layout_bt.x,@layout_bt.y]
  end
  
  #--------------------------------------------------------------------------
  # ● Create Sprite Command Name
  #--------------------------------------------------------------------------
  def create_sprite_command_name
      return if !COMMAND_NAME      
      @old_name_index = self.index
      @sprite_command_name = Sprite.new
      @sprite_command_name.bitmap = Bitmap.new(120,32)
      @sprite_command_name.oy = @sprite_command_name.bitmap.height / 2
      @sprite_command_name.ox = @sprite_command_name.bitmap.width / 2
      @sprite_command_name.z = @sprite_commands[index].z
      @org_cm_name = [@sprite_commands[0].x +  COMMANND_NAME_POSITION[0] + @sprite_command_name.ox -
      (@sprite_command_name.bitmap.width +  @sprite_commands[0].bitmap.width),
                      @sprite_commands[0].y + COMMANND_NAME_POSITION[1]]
      @org_cm_name[0] = @sprite_commands[0].x + COMMANND_NAME_POSITION[0] if COMMAND_TYPE == 4
      @sprite_command_name.x = @org_cm_name[0] 
      @sprite_command_name.y = @org_cm_name[1]
      @sprite_command_name.angle = COMMAND_NAME_ANGLE
      refresh_command_name
  end

  #--------------------------------------------------------------------------
  # ● Refresh Command Name
  #--------------------------------------------------------------------------
  def refresh_command_name
      return if @sprite_command_name == nil
      @old_name_index = self.index
      @sprite_command_name.bitmap.clear
      text = @list[self.index][:name]      
      if COMMAND_TYPE == 4
         @sprite_command_name.bitmap.draw_text(0,0,120,32,text.to_s,1)
      else
         @sprite_command_name.bitmap.draw_text(0,0,120,32,text.to_s,2)
      end   
  end
  
  #--------------------------------------------------------------------------
  # ● Set Window Position
  #--------------------------------------------------------------------------
  def set_window_position
      if FIXED_COMMAND_POSITION[@actor.index] != nil
         @nxy[0] = FIXED_COMMAND_POSITION[@actor.index][0] rescue nil
         @nxy[1] = FIXED_COMMAND_POSITION[@actor.index][1] rescue nil
         @nxy[0] = FIXED_COMMAND_POSITION[0][0] if @nxy[0] == nil
         @nxy[1] = FIXED_COMMAND_POSITION[0][1] if @nxy[1] == nil
         self.viewport = nil
      end    
      unless $imported[:mog_battle_hud_ex]
      return if DEFAULT_COMMAND_POSITION == [0,0] and COMMAND_TYPE == 0
      end
      self.viewport = nil if DEFAULT_COMMAND_POSITION != [0,0]
      if COMMAND_TYPE > 1
         self.x = -Graphics.width
         return
      end      
      cy = Graphics.height - (@stwh[1] + self.height) if COMMAND_TYPE == 1
      cy = 0 if cy == nil           
      self.x = DEFAULT_COMMAND_POSITION[0] + @nxy[0] + @bex[0]
      self.y = DEFAULT_COMMAND_POSITION[1] + @nxy[1] + cy + @bex[1]
   end
        
  #--------------------------------------------------------------------------
  # ● Refresh Sprite Command
  #--------------------------------------------------------------------------
  def refresh_sprite_command(index)
      if CUSTOM_ICONS_COMMANDS
         bitmap = Cache.battle_hud("Com_" + @list[index][:name].to_s)
         s_rect = Rect.new(0,0,bitmap.width,bitmap.height)
         @sprite_commands[index].bitmap.blt(0,0,bitmap,s_rect)        
      else  
          if Vocab::attack == command_name(index)
             icon_index = @actor.equips[0].icon_index rescue nil
          else
             icon_index = COMMAND_ICON_INDEX[command_name(index)] rescue nil
          end 
          icon_index = -1 if icon_index == nil
          bitmap = Cache.system("Iconset")
          s_rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
          @sprite_commands[index].bitmap.blt(0,0,bitmap,s_rect)
      end
      @sprite_commands[index].ox = @sprite_commands[index].bitmap.width / 2
      @sprite_commands[index].oy = @sprite_commands[index].bitmap.height / 2
      @sprite_command_cwh[index] = [@sprite_commands[index].bitmap.width,@sprite_commands[index].bitmap.height]
      set_sprite_icon_command_position(index) if [2,3].include?(COMMAND_TYPE)
      if COMMAND_TYPE == 4
         @sprite_commands[index].x = DEFAULT_COMMAND_POSITION[0] + @nxy[0] + @bex[0]
         @sprite_commands[index].y = DEFAULT_COMMAND_POSITION[1] + @nxy[1] + @bex[1]
      end      
      @sprite_command_org[index] = [@sprite_commands[index].x, @sprite_commands[index].y]
  end  
  
  #--------------------------------------------------------------------------
  # ● Set Sprite Ring Position
  #--------------------------------------------------------------------------
  def update_ring_position(bc_sprite,index) 
      rol_index = RING_COMMAND_RATE / @sprite_commands.size
      si = RING_COMMAND_MOVEMENT ? self.index : 0
      now_p = rol_index * (si - index)
      round = (2.0 * Math::PI / 360) * -now_p
      npx = DEFAULT_COMMAND_POSITION[0] + @nxy[0] + @bex[0]
      npy = DEFAULT_COMMAND_POSITION[1] + @nxy[1] + @bex[1]
      nx = npx - (@roll_range * Math.sin( round )).to_i
      ny = npy - (@roll_range * Math.cos( round )).to_i
      execute_move_rg(bc_sprite,0,bc_sprite.x,nx) 
      execute_move_rg(bc_sprite,1,bc_sprite.y,ny)
  end  
  
  #--------------------------------------------------------------------------
  # ● Execute Move RG
  #--------------------------------------------------------------------------      
  def execute_move_rg(sprite,type,cp,np)
      sp = 5 + ((cp - np).abs / 10)
      if cp > np ;    cp -= sp ; cp = np if cp < np
      elsif cp < np ; cp += sp ; cp = np if cp > np
      end     
      sprite.x = cp if type == 0 ; sprite.y = cp if type == 1
  end    
  
  #--------------------------------------------------------------------------
  # ● Set Sprite Icon Command Position
  #--------------------------------------------------------------------------
  def set_sprite_icon_command_position(index)
      if COMMAND_TYPE == 2
         cw = (@sprite_commands[index].bitmap.width + ICONS_SPACE) * index
         ch = (@sprite_commands[index].bitmap.height + 5)
         cw2 = (@sprite_commands[index].bitmap.width + ICONS_SPACE) * @list.size
         ch2 = (@sprite_commands[index].bitmap.height + 5)
         @sprite_command_cwh[index] = [@sprite_commands[index].bitmap.width + ICONS_SPACE,@sprite_commands[index].bitmap.height + 5]
      else
         cw = (@sprite_commands[index].bitmap.width + 5) 
         ch = (@sprite_commands[index].bitmap.height + ICONS_SPACE) * index
         cw2 = (@sprite_commands[index].bitmap.width + 5) 
         ch2 = (@sprite_commands[index].bitmap.height + ICONS_SPACE) * @list.size
         @sprite_command_cwh[index] = [@sprite_commands[index].bitmap.width + 5,@sprite_commands[index].bitmap.height + ICONS_SPACE]
      end   
      @sc_org = [(Graphics.width - cw2) + cw + DEFAULT_COMMAND_POSITION[0] + @nxy[0],
                 (Graphics.height - ch2) + ch - @sprite_commands[index].bitmap.height - @stwh[1] + DEFAULT_COMMAND_POSITION[1] + @nxy[1]]
      if $imported[:mog_battle_hud_ex] != nil
         @sc_org = [@bex[0] + cw + DEFAULT_COMMAND_POSITION[0] + @nxy[0],
                    @bex[1] + ch + DEFAULT_COMMAND_POSITION[1] + @nxy[1]]              
      end          
      @sprite_commands[index].x = @sc_org[0]
      @sprite_commands[index].y = @sc_org[1]      
  end
      
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  alias mog_battle_command_update update
  def update
      process_cursor_move_left_right
      mog_battle_command_update        
      update_sprite_battle_command      
  end
  
  #--------------------------------------------------------------------------
  # ● Update Sprite Battle Command
  #--------------------------------------------------------------------------
  def update_sprite_battle_command
      force_refresh_battle_command if $game_temp.refresh_battle_command
      update_crm
      if COMMAND_TYPE == 0
         self.visible = cm_visible?
         @layout_bt.visible = self.visible if @layout_bt != nil
      else
         self.visible = cm_visible?
         @layout_bt.visible = bc_visible? if @layout_bt != nil
      end
      update_cursor_cm
      return if @sprite_commands == nil
      @sprite_commands.each_with_index {|sprite,index| update_battle_command(sprite,index) }
      update_command_name
      execute_move_rg(@layout_bt,0,@layout_bt.x,@layout_bt_org[0])
      execute_move_rg(@layout_bt,1,@layout_bt.y,@layout_bt_org[1])      
  end

  #--------------------------------------------------------------------------
  # ● Update Crm
  #--------------------------------------------------------------------------
  def update_crm
      return if @comr == 0
      @comr -= 1
      return if @comr > 0
      refresh ; dispose_battle_command_ex ; bc_setup
  end
  
  #--------------------------------------------------------------------------
  # ● Force Refresh Battle Command
  #--------------------------------------------------------------------------
  def force_refresh_battle_command
      $game_temp.refresh_battle_command = false
      @comr = 4
  end
  
  #--------------------------------------------------------------------------
  # ● CM Visible?
  #--------------------------------------------------------------------------
  def cm_visible?
      return false if $game_message.visible
      return false if $game_temp.battle_end      
      return false if BattleManager.actor == nil      
      if $imported[:mog_battle_hud_ex] == nil
          return true if COMMAND_TYPE == 0 and DEFAULT_COMMAND_POSITION == [0,0] and FIXED_COMMAND_POSITION == []
      end
      return false if !self.active
      return true
  end

  #--------------------------------------------------------------------------
  # ● Update Command Name
  #--------------------------------------------------------------------------
  def update_command_name
      return if @sprite_command_name == nil
      refresh_command_name if @old_name_index != self.index    
      @sprite_command_name.visible = @sprite_commands[0].visible    
  end
  
  #--------------------------------------------------------------------------
  # ● Update Battle Command
  #--------------------------------------------------------------------------
  def update_battle_command(bc_sprite,index)
      bc_sprite.visible = bc_visible?
      update_bc_zoom_effect(bc_sprite,index)
      update_bc_slide_effect(bc_sprite,index)
      update_ring_position(bc_sprite,index) if COMMAND_TYPE == 4
  end
  
  #--------------------------------------------------------------------------
  # ● Update BC Slide Effect
  #--------------------------------------------------------------------------
  def update_bc_slide_effect(bc_sprite,index)
      return if !SLIDE_ANIMATION
      return if !COMMAND_TYPE.between?(2,3)
      if COMMAND_TYPE == 2
            nx = @sprite_command_org[index][0]
            ny = index == self.index ? @sprite_command_org[index][1] - 24 : @sprite_command_org[index][1]
      elsif COMMAND_TYPE == 3            
            nx = index == self.index ? @sprite_command_org[index][0] - 24 : @sprite_command_org[index][0]
            if SCROLL_ROW and self.index > @s_row_max
               ny = @sprite_command_org[index][1] - (@sprite_command_cwh[index][1] * (self.index - @s_row_max))
            else    
               ny = @sprite_command_org[index][1] 
            end
      end
     execute_move_rg(bc_sprite,0,bc_sprite.x,nx)
     execute_move_rg(bc_sprite,1,bc_sprite.y,ny)
     @c_nxy = [@sprite_commands[self.index].x,@sprite_commands[self.index].y]
  end
  
  #--------------------------------------------------------------------------
  # ● Update BC Zoom Effect
  #--------------------------------------------------------------------------
  def update_bc_zoom_effect(bc_sprite,index)
      return if !ZOOM_EFFECT
      if index == self.index
         bc_sprite.opacity += 30
         if LOOP_ZOOM_ANIMATION
         if @sprite_zoom_phase[index] == 0
            bc_sprite.zoom_x += 0.02
            if bc_sprite.zoom_x >= 1.5
               bc_sprite.zoom_x = 1.5 ; @sprite_zoom_phase[index] = 1
            end   
         else  
            bc_sprite.zoom_x -= 0.02
            if bc_sprite.zoom_x <= 1.0
               bc_sprite.zoom_x = 1.0 ; @sprite_zoom_phase[index] = 0
            end   
         end
         else
            bc_sprite.zoom_x += 0.1 if bc_sprite.zoom_x < 1.50
         end  
      else  
         bc_sprite.zoom_x -= 0.1 if bc_sprite.zoom_x > 1.00
         @sprite_zoom_phase[index] = 0
         bc_sprite.opacity -= 20 if bc_sprite.opacity  > 160         
      end
      bc_sprite.zoom_y = bc_sprite.zoom_x
  end    
      
  #--------------------------------------------------------------------------
  # ● BC Visible?
  #--------------------------------------------------------------------------
  def bc_visible?
      return false if !self.visible
      return false if self.openness < 255
      return false if !self.active
      return true
  end
    
end

#==============================================================================
# ■ Window_BattleActor Face
#==============================================================================
class Window_BattleActor_Face < Window_Base
   
  attr_accessor :actor
   
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
      super
      @actor = nil
  end
 
  #--------------------------------------------------------------------------
  # ● Get Window Width
  #--------------------------------------------------------------------------
  def window_width
      (Graphics.width - 128)
  end  
  
  #--------------------------------------------------------------------------
  # ● Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
      return if @actor == actor
      @actor = actor     
  end

  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
      return if @actor == nil
      self.contents.clear
      self.visible = true
      self.contents_opacity = 255
      draw_face(@actor.face_name, @actor.face_index, 0, 0, true)
  end  
  
end

#==============================================================================
# ■ Battle Manager
#==============================================================================
class << BattleManager
 
  #--------------------------------------------------------------------------
  # ● Process Victory
  #--------------------------------------------------------------------------      
  alias mog_bt_command_process_victory process_victory
  def process_victory
      $game_temp.battle_end = true
      mog_bt_command_process_victory
  end
   
  #--------------------------------------------------------------------------
  # ● Process Defeat
  #--------------------------------------------------------------------------      
  alias mog_bt_command_defeat process_defeat
  def process_defeat
      $game_temp.battle_end = true
      mog_bt_command_defeat
  end
  
  #--------------------------------------------------------------------------
  # ● Process Abort
  #--------------------------------------------------------------------------      
  alias mog_bt_command_process_abort process_abort
  def process_abort
      $game_temp.battle_end = true
      mog_bt_command_process_abort
  end
  
end
