#==============================================================================
# +++ MOG - Aura Effect (1.8) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# O script adiciona o efeito animado de aura no sprite do battler.
#==============================================================================

#==============================================================================
# ● UTILIZAÇÃO
#==============================================================================
# Adicione o comentário abaixo na caixa de notas dos inimigos ou aliados.
#
# <Aura Effect = X>
# 
# X = Tipo de Efeito
#     0 - Zoom In & Out
#     1 - Zoom Out
#==============================================================================
# ● Gráfico
#==============================================================================
# Nomeie a imagem da aura da seguinte forma.
#
# Enemy + ID + _Aura.png
#
# Enemy4_Aura.png
#
# No caso de não haver o gráfico da aura o script vai selecionar o mesmo gráfico
# utilizado pelo battler.
# Coloque as imagens na pasta Graphics/Pictures/
#==============================================================================

#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v 1.8 - Melhoria no sistema de visibilidade.
# v 1.7 - Correção do sprite no efeito mirror.
#       - Adição do efeito Magic Circle.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_aura_effect] = true

#==============================================================================
# ■ Game BattlerBase
#==============================================================================
class Game_BattlerBase
  attr_accessor :aura_effect
end

#==============================================================================
# ■ Game_Actor
#==============================================================================
class Game_Actor < Game_Battler
  
  #--------------------------------------------------------------------------
  # ● Setup
  #--------------------------------------------------------------------------
  alias mog_aura_effect_setup setup
  def setup(actor_id)
      mog_aura_effect_setup(actor_id)
      @aura_effect = actor.note =~ /<Aura Effect>/ ? true : nil
  end
  
end

#==============================================================================
# ■ Game Enemy
#==============================================================================
class Game_Enemy < Game_Battler  
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_aura_effect_initialize initialize
  def initialize(index, enemy_id)
      mog_aura_effect_initialize(index, enemy_id)
      @aura_effect = enemy.note =~ /<Aura Effect = (\d+)>/i ? $1 : nil
  end  

end

#==============================================================================
# ■ Sprite Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  alias mog_aura_effect_dispose dispose
  def dispose
      dispose_aura_sprite
      mog_aura_effect_dispose
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Aura
  #--------------------------------------------------------------------------  
  def dispose_aura_sprite
      return if @aura_sprite == nil
      @aura_sprite.bitmap.dispose rescue nil
      @aura_sprite.dispose
  end 
  
  #--------------------------------------------------------------------------
  # ● Init Visibility
  #--------------------------------------------------------------------------  
  alias mog_aura_effect_init_visibility init_visibility
  def init_visibility      
      create_aura_sprite
      mog_aura_effect_init_visibility
  end
  
  #--------------------------------------------------------------------------
  # ● Can Create Aura Sprite
  #--------------------------------------------------------------------------  
  def can_create_aura_sprite?
      return false if @aura_sprite != nil
      return false if @battler == nil
      return false if @battler.aura_effect == nil
      return false if @battler.dead?
      return true
  end
    
  #--------------------------------------------------------------------------
  # ● Create Aura Sprite
  #--------------------------------------------------------------------------    
  def create_aura_sprite
      return unless can_create_aura_sprite?
      @aura_sprite = Sprite.new
      @aura_sprite.viewport = self.viewport
      if @battler.is_a?(Game_Actor)
         battler_name = "Actor" + @battler.id.to_s + "_Aura"
      else
         battler_name = "Enemy" + @battler.enemy_id.to_s + "_Aura"
      end
      @aura_sprite.bitmap = Cache.picture(battler_name.to_s) rescue nil
      @aura_sprite.bitmap = self.bitmap if @aura_sprite.bitmap == nil
      @aura_sprite.ox = @aura_sprite.bitmap.width / 2
      @aura_sprite.oy = @aura_sprite.bitmap.height / 2
      @aura_sprite_effect = [@battler.aura_effect.to_i,rand(40),self.bitmap.height / 2]
      @aura_sprite_effect[1] = 0 if [0,2].include?(@aura_sprite_effect[0])
      update_aura
  end
  
  #--------------------------------------------------------------------------
  # ● Update Position
  #--------------------------------------------------------------------------      
  alias mog_aura_update_position update_position
  def update_position
      mog_aura_update_position
      update_aura 
  end

  #--------------------------------------------------------------------------
  # ● Can Update Aura Effect?
  #--------------------------------------------------------------------------          
  def can_update_aura_effet?
      return false if !@battler.exist? 
      return false if !self.visible
      if $imported[:mog_battler_motion] != nil
         return false if @battler.motion_action[0] == 1
         return false if @wait_motion_start != nil and @wait_motion_start == true
      end  
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Update Aura
  #--------------------------------------------------------------------------        
  def update_aura
      return if @aura_sprite == nil
      if !can_update_aura_effet?
         @aura_sprite.opacity = 0
         return 
      end
      return if !@aura_sprite.visible
      @aura_sprite.x = self.x      
      @aura_sprite.z = self.z - 1      
      if @battler.hp == 0
         @aura_sprite.opacity -= 5
         @aura_sprite.visible = false if @aura_sprite.opacity == 0
      else
         case @aura_sprite_effect[0]    
             when 0; update_aura_effect 
             when 1; update_aura_effect2
             when 2; update_aura_effect3
         end   
      end   
  end

  #--------------------------------------------------------------------------
  # ● Update Aura Effect
  #--------------------------------------------------------------------------          
  def update_aura_effect
      @aura_sprite.y = self.y - @aura_sprite.oy
      @aura_sprite.mirror = self.mirror ; @aura_sprite_effect[1] += 1
      @aura_sprite.angle = self.angle
      case @aura_sprite_effect[1]
           when 1..30
             @aura_sprite.zoom_x += 0.002 ; @aura_sprite.opacity -= 5
           when 31..60  
             @aura_sprite.zoom_x -= 0.002 ; @aura_sprite.opacity += 5
           else
             @aura_sprite_effect[1] = 0 ;  @aura_sprite.opacity = 255
             @aura_sprite.zoom_x = 1.00
      end
      @aura_sprite.zoom_y = @aura_sprite.zoom_x
 end  
  
  #--------------------------------------------------------------------------
  # ● Update Aura Effect 2
  #--------------------------------------------------------------------------          
  def update_aura_effect2
      @aura_sprite.y = self.y - @aura_sprite.oy
      @aura_sprite.mirror = self.mirror ; @aura_sprite_effect[1] += 1 
      @aura_sprite.angle = self.angle
      case @aura_sprite_effect[1]
           when 1..60
             @aura_sprite.zoom_x += 0.005 ; @aura_sprite.opacity -= 5
           else
             @aura_sprite_effect[1] = 0 ; @aura_sprite.opacity = 255
             @aura_sprite.zoom_x = 1.00
      end
      @aura_sprite.zoom_y = @aura_sprite.zoom_x
 end

  #--------------------------------------------------------------------------
  # ● Update Aura Effect 3
  #--------------------------------------------------------------------------          
  def update_aura_effect3
      @aura_sprite.y = self.y - @aura_sprite_effect[2]
      @aura_sprite.angle += 2 ; @aura_sprite.blend_type = 1
      @aura_sprite.opacity += 5 ; @aura_sprite_effect[1] += 1
      case @aura_sprite_effect[1]
           when 0..60 ; @aura_sprite.zoom_x += 0.005 
           when 61..120 ; @aura_sprite.zoom_x -= 0.005
           else ; @aura_sprite_effect[1] = 0 ; @aura_sprite.zoom_x = 1.00
      end
      @aura_sprite.zoom_y = @aura_sprite.zoom_x
 end 
 
end