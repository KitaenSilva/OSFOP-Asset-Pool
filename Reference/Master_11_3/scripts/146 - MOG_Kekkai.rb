#==============================================================================
# +++ MOG - Kekkai (Bounded Field) (v1.4) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
# Permite o inimigo invocar uma barreira mágica (Kekkai / Bounded Field) 
# onde serão adicionadas regras no campo de batalha. O sistema inclúi 
# efeitos animados simulando o Kekkai ativado.
#==============================================================================

#==============================================================================
# ● UTILIZAÇÃO
#==============================================================================
# Modo 1 (Event)
# Use o comando abaixo através do comando chamar script.
# 
# kekkai(ID)
#
# ID do Kekkai
#
#==============================================================================
# Modo 2 (Skill)
# Coloque o comentário abaixo na caixa de notas de habilidades .
#
# <Kekkai = ID>
#
#==============================================================================
# Para cancelar o Kekkai use o comando abaixo.
#
# kekkai_clear
#
#==============================================================================

#==============================================================================
# ● As imagens devem ser gravadas na pasta Graphics/Pictures/
#==============================================================================
module MOG_KEKKAI
  
  BOUNDED_FIELD = [] # ☢CAUTION!!☢ Don't Touch.^_^
  
  #BOUNDED_FIELD[A] = [B,C,D]
  # A = FIELD ID.
  # B = Description (Kekkai Title).
  #
  # C = Effect Type.
  #       0 - Enemy Power UP
  #       1 - Enemy Defense UP
  #       2 - Enemy Invulnerable.
  #       3 - Party Damage Reverse.
  #       4 - Party always 1 HP or 0 HP.
  #       5 - Party always 0 MP.
  #       6 - Party Power Down.
  #       7 - Party Defense Down.
  #       8 - Seal Skill & Guard Command.
  #       9 - Seal All Commands. (Except Guard Command)
  #      10 - Slip HP Damage.
  #      11 - Slip MP Damage.
  #
  # D = Background File Name.
  # E = Background Animation Type.
  #       0 - Scrolling 
  #       1 - Wave
  # F = Scroll Speed X / Wave Power. (0 - 10)
  # G = Scroll Speed Y / Wave Speed. (0 - 10)
  # H = Opacity. (0,255)
  # I = Blend Type. (0- Normal / 1 - Add / 2 - Substract)
  
  BOUNDED_FIELD[1] = ["Curse  of  Dreams  and  Reality.", #Kekkai Name
                       3,          # Effect Type
                       "Background_1",  # Picture file Name
                       1,          # Animation Type
                       4,          # Scroll Speed X
                       4,          # Scroll Speed Y
                       150,        # Opacity
                       0           # Blend Type 
                       ]                       
  BOUNDED_FIELD[2] = ["Balance of Motion and Stillness.",5, "Kekkai1", 0,1,1,255,0]
  BOUNDED_FIELD[3] = ["Mesh of Light and Darkness.",9, "Background_1", 1,4,10,250,2]
  BOUNDED_FIELD[4] = ["Boundary of Humans and Youkai",2, "Background_5", 1,4,4,155,0]
  BOUNDED_FIELD[5] = ["Boundary of Life and Death.",4, "Background_8", 0,0,0,255,0]
  BOUNDED_FIELD[6] = ["Boundary of Life and Death.",4, "Background_8", 1,1,1,255,0]
  BOUNDED_FIELD[7] = ["Hakurei Dai-Kekkai.", 
                       3,          # Effect Type
                       "Reimu_Hakurei",  # Picture file Name
                       1,          # Animation Type
                       4,          # Scroll Speed X
                       4,          # Scroll Speed Y
                       150,        # Opacity
                       1           # Blend Type 
                       ]     
  #Definição do poder de ataque do campo.
  ATTACK_PERC = 100
  
  #Definição do poder de defesa do campo.
  DEFENSE_PERC = 100
  
  #Porcentagem de dano no efeito Slip.
  SLIP_DAMAGE_PERC = 20
  
  #Posição do texto (Title). (x,y)
  TEXT_POSITION = [310,0]
  
  #Alinhamento do texto. (0..2)
  TEXT_ALIGN = 1
  
  #Ativar o efeito de zoom no texto.
  TEXT_ZOOM_EFFECT = true
  
  #Definição da cor da fonte.  
  FONT_COLOR = Color.new(255,255,255)
  
  #Apresentar os efeitos em danos. (*É preciso ter o script MOG_Damage_Popup) 
  EFFECT_POPUP = true
  EFFECT_POPUP_WORD = "Kekkai Effect"
  EFFECT_POPUP_INVUNERABLE_WORD = "Invulnerable"
  EFFECT_POPUP_REVERSE_DAMAGE_WORD = "Reverse Effect"
end
#==============================================================================
# ● Histórico (Version History)
#==============================================================================
# v 1.4 - Compatibilidade com MOG Battle Camera.
# v 1.3 - Compatibilidade com o MOG ATB.
# v 1.2 - Correção na compatibilidade com o script Advanced Battle Hud.
#         No efeito Drain.
# v 1.1 - Melhoria na codificação.
#==============================================================================

#==============================================================================
# ■ Game Temp
#==============================================================================
class Game_Temp
  
  attr_accessor :kekkai
  attr_accessor :battle_end
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_bounded_field_initialize initialize
  def initialize
      @kekkai = [false,nil,nil]
      @battle_end = false
      mog_bounded_field_initialize 
  end  

end

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # ● Bounded Field
  #--------------------------------------------------------------------------  
  def kekkai(id = nil)
      id = nil if id < 1
      $game_temp.kekkai = [true,id]
  end
  
  #--------------------------------------------------------------------------
  # ● Clear  Kekkai
  #--------------------------------------------------------------------------    
  def kekkai_clear
      $game_temp.kekkai = [true,nil]
  end  
  
  #--------------------------------------------------------------------------
  # ● Clear Bounded Field 
  #--------------------------------------------------------------------------    
  def clear_bounded_field
      $game_temp.kekkai = [true,nil]
  end
  
end

#==============================================================================
# ■ Bounded Field
#==============================================================================
class Bounded_Field

  include MOG_KEKKAI
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  def initialize(viewport = nil)
      $game_temp.kekkai = [false,nil]
      $game_temp.battle_end = false
      @effect = ["",0,"",0,0,0,0,0]
      @phase = 0
      create_kekkai_text(viewport)
  end

  #--------------------------------------------------------------------------
  # ● Create Kekkai Layer
  #--------------------------------------------------------------------------    
  def create_kekkai_layer
      if @effect[3] == 0
         @kekkai_1 = Plane.new
         @kekkai_1.bitmap = Cache.picture(@effect[2].to_s)
         stretch_battleback(@kekkai_1) if $imported[:mog_battle_camera]
         @kekkai_1.ox = @kekkai_1.bitmap.width / 2 
         @kekkai_1.oy = @kekkai_1.bitmap.height / 2         
       else 
         range = (@effect[4] + 1) * 10 ;  range = 500 if range > 500
         if $imported[:mog_battle_camera]
           camera_range = [[$game_system.battle_camera_range.abs, 100].min, 0].max
           rxy = [Graphics.width * camera_range / 100,Graphics.height * camera_range / 100]
         else
           rxy = [0,0]
         end
         speed = (@effect[5] + 1) * 100
         speed = 1000 if speed > 1000                  
         @kekkai_image = Cache.picture(@effect[2].to_s)
         @kekkai_1 = Sprite.new
         @kekkai_1.x = -range
         @kekkai_1.wave_amp = range
         @kekkai_1.wave_length = Graphics.width
         @kekkai_1.wave_speed = speed
         @kekkai_1.bitmap = Bitmap.new(Graphics.width + rxy[0] + (range * 2),Graphics.height + rxy[1])
         @kekkai_1.bitmap.stretch_blt(@kekkai_1.bitmap.rect, @kekkai_image, @kekkai_image.rect) 
         center_sprite(@kekkai_1)
      end
  end
 
  #--------------------------------------------------------------------------
  # ● Stretch Battleback
  #--------------------------------------------------------------------------  
  def stretch_battleback(sprite)
      return if !$game_system.battle_camera
      return if !MOG_BATTLE_CAMERA::BATTLEBACK_STRETCH
      return if sprite == nil
      camera_range = [[$game_system.battle_camera_range.abs, 100].min, 0].max
      old_bitmap = sprite.bitmap ; perc_s = 105 + camera_range
      perc_w = Graphics.width * perc_s / 100 
      perc_h = Graphics.height * perc_s / 100
      sprite.bitmap = Bitmap.new(perc_w,perc_h) 
      sprite.bitmap.stretch_blt(sprite.bitmap.rect, old_bitmap, old_bitmap.rect)
  end  

  #--------------------------------------------------------------------------
  # ● Center Sprite
  #--------------------------------------------------------------------------    
  def center_sprite(sprite)
      sprite.ox = sprite.bitmap.width / 2 
      sprite.oy = sprite.bitmap.height / 2
      sprite.x = Graphics.width / 2 
      sprite.y = Graphics.height / 2 
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh Kekkai Layer
  #--------------------------------------------------------------------------      
  def refresh_kekkai_layer
      dispose_kekkai_layer
      create_kekkai_layer
      @kekkai_1.viewport = @kekkai_text.viewport rescue nil
      @kekkai_1.z = 9
      @kekkai_1.opacity = 0
      @kekkai_1.blend_type = @effect[7]
      @kekkai_1.visible = true
  end
    
  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------    
  def dispose
      dispose_kekkai_layer
      dispose_kekkai_text
      $game_temp.kekkai = [false,nil]
  end
  
  #--------------------------------------------------------------------------
  # ● Dispose Kekkai Layer
  #--------------------------------------------------------------------------      
  def dispose_kekkai_layer
      return if @kekkai_1 == nil
      if @kekkai_1.bitmap != nil
         @kekkai_1.bitmap.dispose
         @kekkai_1.bitmap = nil
      end   
      @kekkai_1.dispose
      @kekkai_1 = nil
      if @kekkai_image != nil
         @kekkai_image.dispose
         @kekkai_image = nil
      end   
  end   
  
  #--------------------------------------------------------------------------
  # ● Dispose kekkai Text Bitmap
  #--------------------------------------------------------------------------            
  def dispose_kekkai_text_bitmap
      return if @kekkai_text == nil
      return if @kekkai_text.bitmap == nil
      @kekkai_text.bitmap.dispose
      @kekkai_text.bitmap = nil
  end    
  
  #--------------------------------------------------------------------------
  # ● Dispose Kekkai Text
  #--------------------------------------------------------------------------      
  def dispose_kekkai_text
      return if @kekkai_text == nil
      dispose_kekkai_text_bitmap
      @kekkai_text.dispose
      @kekkai_text = nil
  end
  
  #--------------------------------------------------------------------------
  # ● Create Kekkai Text
  #--------------------------------------------------------------------------        
  def create_kekkai_text(viewport)
      @kekkai_text_duration = 0
      @kekkai_text = Sprite.new
      @kekkai_text.viewport = viewport
      @kekkai_text.z = 160
      @kekkai_text.ox = 120
      @kekkai_text.oy = 16
      @kekkai_text.x = @kekkai_text.ox + TEXT_POSITION[0]
      @kekkai_text.y = @kekkai_text.oy + TEXT_POSITION[1]
      @kekkai_text.visible = false
      refresh_kekkai_text
  end
  
  #--------------------------------------------------------------------------
  # ● Refresh Kekkai Text
  #--------------------------------------------------------------------------          
  def refresh_kekkai_text
      dispose_kekkai_text_bitmap
      @kekkai_text_duration = 0 
      @kekkai_text.bitmap = Bitmap.new(240,32)
      text = @effect[0]
      @kekkai_text.bitmap.font.size = 22
      @kekkai_text.bitmap.font.bold = true
      @kekkai_text.bitmap.font.color = Color.new(0,0,0)
      @kekkai_text.bitmap.draw_text(0,0,240,32,text.to_s, TEXT_ALIGN)
      @kekkai_text.bitmap.font.color = FONT_COLOR
      @kekkai_text.bitmap.draw_text(2,2,240,32,text.to_s, TEXT_ALIGN)
      @kekkai_text.zoom_x = 1.00
      @kekkai_text.zoom_y = 1.00
      @kekkai_text.opacity = 0
      @kekkai_text.visible = true
      if $imported[:mog_battle_command_ex]        
         $game_temp.refresh_battle_command = true #if [8,9].include?(@effect[1])
      end
  end  
  
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------    
  def update
      refresh_kekkai if can_refresh_kekkai?
      update_kekkai if can_update_kekkai?
  end

  #--------------------------------------------------------------------------
  # ● Can Refresh Kekkain?
  #--------------------------------------------------------------------------      
  def can_refresh_kekkai?
      return false if !$game_temp.kekkai[0]
      return true 
  end

  #--------------------------------------------------------------------------
  # ● Can Update Kekkai?
  #--------------------------------------------------------------------------        
  def can_update_kekkai?
      return false if @phase == 0
      return true
  end
    
  #--------------------------------------------------------------------------
  # ● Refresh Kekkai
  #--------------------------------------------------------------------------      
  def refresh_kekkai
      $game_temp.kekkai[0] = false      
      @effect = BOUNDED_FIELD[$game_temp.kekkai[1]] rescue nil
      if @effect != nil
         refresh_party_effects
         refresh_kekkai_layer
         refresh_kekkai_text
         @phase = 1
      else 
         @phase = 2
      end  
  end  
  
  #--------------------------------------------------------------------------
  # ● Refresh Party Effects
  #--------------------------------------------------------------------------        
  def refresh_party_effects
      if @effect[1] == 4 or @effect[1] == 5
         index = 0
         for i in $game_party.members
             i.hp = 1 if i.hp != 0 and @effect[1] == 4
             i.mp = 0 if @effect[1] == 5
             if $mog_rgss3_battle_hud != nil
                i.battler_face = [3,0,40]
             end   
             if $imported[:mog_damage_popup] != nil and MOG_KEKKAI::EFFECT_POPUP
                i.damage.push([MOG_KEKKAI::EFFECT_POPUP_WORD,"Kekkai Effect"])
             end                    
             index += 1
             break if index >= $game_party.max_battle_members 
         end  
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Kekkai 
  #--------------------------------------------------------------------------        
  def update_kekkai
      update_kekkai_layer
      update_kekkai_text
      if !$game_temp.battle_end 
          if @phase == 1
             if  @kekkai_1.opacity < @effect[6]
                 @kekkai_1.opacity += 5
                 @kekkai_1.opacity = @effect[6] if @kekkai_1.opacity > @effect[6]
             end    
             @kekkai_text.opacity += 5
          elsif @phase == 2
             update_kekkai_clear
          end
      else
          update_fade_sprite
      end  
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Kekkai Layer
  #--------------------------------------------------------------------------         
  def update_kekkai_layer
      return if @kekkai_1 == nil
      return if @effect == nil      
      if @effect[3] == 0
         @kekkai_1.ox += @effect[4]
         @kekkai_1.oy += @effect[5]
      else
         @kekkai_1.update 
      end
  end  
    
  #--------------------------------------------------------------------------
  # ● Update Kekkai Text
  #--------------------------------------------------------------------------          
  def update_kekkai_text
      return if @kekkai_text == nil
      return if !@kekkai_text.visible
      return if !TEXT_ZOOM_EFFECT
      if $imported[:mog_battle_camera] 
         @kekkai_text.ox = -$game_temp.viewport_oxy[0] + 120
         @kekkai_text.oy = -$game_temp.viewport_oxy[1] + 16
      end
      @kekkai_text_duration += 1
      case @kekkai_text_duration
         when 1..20
           @kekkai_text.zoom_x += 0.005
           @kekkai_text.zoom_y += 0.005         
         when 21..40
           @kekkai_text.zoom_x -= 0.005
           @kekkai_text.zoom_y -= 0.005                  
         else  
           @kekkai_text.zoom_x = 1.00
           @kekkai_text.zoom_y = 1.00
           @kekkai_text_duration = 0
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Update Kekkai Clear
  #--------------------------------------------------------------------------          
  def update_kekkai_clear
      return if @phase == 0
      return if @kekkai_1 == nil
      @kekkai_1.opacity -= 5
      @kekkai_text.opacity -= 5
      if @kekkai_1.opacity == 0
         dispose_kekkai_layer
         dispose_kekkai_text_bitmap
         @kekkai_text.visible = false
         @phase = 0
      end    
  end
  
  #--------------------------------------------------------------------------
  # ● Update Fade Sprite
  #--------------------------------------------------------------------------            
  def update_fade_sprite
      if @kekkai_1 != nil
         @kekkai_1.opacity -= 5
      end
      if @kekkai_text != nil
         @kekkai_text.opacity -= 5 
      end  
  end  
   
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------  
  alias mog_bounded_field_initialize initialize
  def initialize
      mog_bounded_field_initialize
      create_bounded_field
  end

  #--------------------------------------------------------------------------
  # ● Dispose
  #--------------------------------------------------------------------------  
  alias mog_bounded_field_dispose dispose
  def dispose
      dispose_bounded_field
      mog_bounded_field_dispose      
  end

  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------  
  alias mog_bounded_field_update update
  def update
      mog_bounded_field_update
      update_bounded_field
  end

  #--------------------------------------------------------------------------
  # ● Create Bounded Field
  #--------------------------------------------------------------------------    
  def create_bounded_field
      @bounded_field = Bounded_Field.new(@viewport1)
  end

  #--------------------------------------------------------------------------
  # ● Dispose Bounded Field
  #--------------------------------------------------------------------------    
  def dispose_bounded_field
      return if @bounded_field == nil
      @bounded_field.dispose
  end

  #--------------------------------------------------------------------------
  # ● Update Bounded Field
  #--------------------------------------------------------------------------    
  def update_bounded_field
      return if @bounded_field == nil
      @bounded_field.update
  end

end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # ● Bounded Effect
  #--------------------------------------------------------------------------        
  def bounded_effect 
      MOG_KEKKAI::BOUNDED_FIELD[$game_temp.kekkai[1]] rescue nil
  end    
  
  #--------------------------------------------------------------------------
  # ● Execute Damage
  #--------------------------------------------------------------------------      
  alias mog_bounded_field_execute_damage execute_damage
  def execute_damage(user)      
      execute_bounded_field_effects_before(user,bounded_effect) if bounded_effect != nil
      mog_bounded_field_execute_damage(user)
      execute_bounded_field_effects_after(user,bounded_effect) if bounded_effect != nil
  end
  
  #--------------------------------------------------------------------------
  # ● Item Apply
  #--------------------------------------------------------------------------        
  alias mog_bounded_field_item_apply item_apply
  def item_apply(user, item)
      return if bounded_nil_effect_enemy?(user)
      mog_bounded_field_item_apply(user, item)
  end
  
  #--------------------------------------------------------------------------
  # ● Bounded Nil Effect Enemy?
  #--------------------------------------------------------------------------          
  def bounded_nil_effect_enemy?(user)
      return false if bounded_effect == nil
      return false if self.is_a?(Game_Actor)
      return false if user.is_a?(Game_Enemy)
      return false if bounded_effect[1] != 2
      if $imported[:mog_damage_popup] != nil and MOG_KEKKAI::EFFECT_POPUP
         self.damage.push([MOG_KEKKAI::EFFECT_POPUP_INVUNERABLE_WORD,"Invunerable"]) if bounded_effect[1] == 2 
      end
      @result.clear
      return true
  end  

  #--------------------------------------------------------------------------
  # ● Execute Bounded Field Effects Before
  #--------------------------------------------------------------------------        
  def execute_bounded_field_effects_before(user,bounded_effect)
      case bounded_effect[1]
          when 0; bounded_power_effect(user)
          when 1; bounded_defense_effect(user)
          when 2; bounded_invunerable_effect(user)
          when 3; bounded_reverse_damage_effect(user)
          when 4; bounded_nil_drain_hp(user)
          when 5; bounded_nil_drain_mp(user)
          when 6; bounded_power_effect_actor(user)
          when 7; bounded_defense_effect_actor(user)            
      end
  end
    
  #--------------------------------------------------------------------------
  # ● Execute Bounded Field Effects After
  #--------------------------------------------------------------------------        
  def execute_bounded_field_effects_after(user,bounded_effect)
      case bounded_effect[1]
           when 4; bounded_nil_actor_recover_hp(user)
           when 5; bounded_nil_actor_recover_mp(user)
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Bounded Power Effect
  #--------------------------------------------------------------------------          
  def bounded_power_effect(user)
      return if self.is_a?(Game_Enemy)
      return if user.is_a?(Game_Actor)
      dam = @result.hp_damage * MOG_KEKKAI::ATTACK_PERC / 100
      dam = 0 if dam < 0
      @result.hp_damage += dam
  end

  #--------------------------------------------------------------------------
  # ● Bounded Power Effect User
  #--------------------------------------------------------------------------          
  def bounded_power_effect_actor(user)
      return if user.is_a?(Game_Enemy)
      return if @result.hp_damage < 0
      dam = @result.hp_damage * MOG_KEKKAI::ATTACK_PERC / 100
      dam = 0 if dam < 0
      @result.hp_damage -= dam
      @result.hp_damage = 0 if @result.hp_damage < 0
  end  
  
  #--------------------------------------------------------------------------
  # ● Bounded Defense Effect
  #--------------------------------------------------------------------------          
  def bounded_defense_effect(user)
      return if self.is_a?(Game_Actor)
      return if user.is_a?(Game_Enemy)
      dam = @result.hp_damage * MOG_KEKKAI::DEFENSE_PERC / 100
      dam2 = @result.hp_damage - dam
      dam2 = 0 if dam2 < 0
      @result.hp_damage = dam2
  end  

  #--------------------------------------------------------------------------
  # ● Bounded Defense Effect Actor
  #--------------------------------------------------------------------------          
  def bounded_defense_effect_actor(user)
      return if self.is_a?(Game_Enemy)
      dam = @result.hp_damage * MOG_KEKKAI::DEFENSE_PERC / 100
      dam2 = @result.hp_damage + dam
      dam2 = 0 if dam2 < 0
      @result.hp_damage = dam2
  end    
  
  #--------------------------------------------------------------------------
  # ● Bounded Invunerable Effect
  #--------------------------------------------------------------------------          
  def bounded_invunerable_effect(user)
      return if self.is_a?(Game_Actor)
      return if user.is_a?(Game_Enemy)
      @result.hp_damage = 0
  end

  #--------------------------------------------------------------------------
  # ● Bounded Reverse Damage Effect
  #--------------------------------------------------------------------------          
  def bounded_reverse_damage_effect(user)
      return if @result.hp_damage == 0
      return if user.is_a?(Game_Enemy)
      if $imported[:mog_damage_popup] != nil and MOG_KEKKAI::EFFECT_POPUP
         self.damage.push([MOG_KEKKAI::EFFECT_POPUP_REVERSE_DAMAGE_WORD,"Reverse Effect"]) 
      end         
      @result.hp_damage = -@result.hp_damage 
      if @result.hp_drain != nil and @result.hp_drain != 0
         @result.hp_drain = -@result.hp_drain 
         if $mog_rgss3_battle_hud != nil
            user.battler_face = [3,0,40]
         end
      end
  end

  #--------------------------------------------------------------------------
  # ● Bounded Nil Drain HP
  #--------------------------------------------------------------------------              
  def bounded_nil_drain_hp(user)
      return if self.is_a?(Game_Actor)
      @result.hp_drain = 0
  end
  
  #--------------------------------------------------------------------------
  # ● Bounded Nil Actor Recover HP
  #--------------------------------------------------------------------------            
  def bounded_nil_actor_recover_hp(user)
      return if self.is_a?(Game_Enemy)
      @result.hp_drain = 0
      self.hp = 1 if self.hp > 1
  end  
  
  #--------------------------------------------------------------------------
  # ● Bounded Nil Drain MP
  #--------------------------------------------------------------------------              
  def bounded_nil_drain_mp(user)
      return if self.is_a?(Game_Actor)
      @result.mp_drain = 0
  end
    
  #--------------------------------------------------------------------------
  # ● Bounded Nil Actor Recover MP
  #--------------------------------------------------------------------------            
  def bounded_nil_actor_recover_mp(user)
      return if self.is_a?(Game_Enemy)
      self.mp = 0
  end

  #--------------------------------------------------------------------------
  # ● Item Effect Recover HP
  #--------------------------------------------------------------------------
  alias mog_bounded_field_item_effect_recover_hp item_effect_recover_hp
  def item_effect_recover_hp(user, item, effect)
      if bounded_effect != nil and bounded_effect[1] == 3
         execute_bounded_reverse_item_hp(user, item, effect)
         return
      end  
      mog_bounded_field_item_effect_recover_hp(user, item, effect)
      if bounded_effect != nil and self.is_a?(Game_Actor)
         execute_bounded_seal_hp
      end
  end    
    
  #--------------------------------------------------------------------------
  # ● Execute Bounded Reverse Item HP
  #--------------------------------------------------------------------------  
  def execute_bounded_reverse_item_hp(user, item, effect)
      if $mog_rgss3_damage_pop != nil and MOG_KEKKAI::EFFECT_POPUP
         self.damage.push(["Reverse Effect","Reverse Effect"]) 
      end    
      value = (mhp * effect.value1 + effect.value2) * rec
      value *= user.pha if item.is_a?(RPG::Item)
      value = -value.to_i
      @result.hp_damage -= value
      @result.success = true
      self.hp += value
  end
       
  #--------------------------------------------------------------------------
  # ● Execute Bounded seal HP
  #--------------------------------------------------------------------------  
  def execute_bounded_seal_hp
      return if bounded_effect[1] != 4
      self.hp = 1 if self.hp > 0
  end

  #--------------------------------------------------------------------------
  # ● Item Effect Recover MP
  #--------------------------------------------------------------------------
  alias mog_bounded_field_item_effect_recover_mp item_effect_recover_mp
  def item_effect_recover_mp(user, item, effect)
      mog_bounded_field_item_effect_recover_mp(user, item, effect)
      if bounded_effect != nil and self.is_a?(Game_Actor)
         execute_bounded_seal_mp
      end   
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Bounded seal MP
  #--------------------------------------------------------------------------  
  def execute_bounded_seal_mp
      return if bounded_effect[1] != 5
      self.mp = 0 if self.mp > 0
  end
    
  #--------------------------------------------------------------------------
  # ● Regenerate HP
  #--------------------------------------------------------------------------            
  alias mog_bounded_field_regenerate_hp regenerate_hp
  def regenerate_hp
      mog_bounded_field_regenerate_hp
      if bounded_effect != nil and self.is_a?(Game_Actor)
         execute_bounded_slip_hp
         execute_bounded_seal_hp
      end
  end  
  
  #--------------------------------------------------------------------------
  # ● Regenerate mp
  #--------------------------------------------------------------------------              
  alias mog_bounded_field_regenerate_mp regenerate_mp
  def regenerate_mp
      mog_bounded_field_regenerate_mp
      if bounded_effect != nil and self.is_a?(Game_Actor)
         execute_bounded_slip_mp
         execute_bounded_seal_mp
      end
  end    
  
  #--------------------------------------------------------------------------
  # ● Execute Bounded Slip HP
  #--------------------------------------------------------------------------                
  def execute_bounded_slip_hp
      return if bounded_effect[1] != 10
      return if self.hp <= 1
      dmg = self.mhp * MOG_KEKKAI::SLIP_DAMAGE_PERC  / 100
      dmg = 1 if dmg < 1
      dmg = self.hp - 1 if dmg > self.hp
      self.hp -= dmg if self.hp > 0
      if $imported[:mog_damage_popup] != nil and MOG_KEKKAI::EFFECT_POPUP
         self.damage.push([dmg,"HP"])
         self.damage.push([MOG_KEKKAI::EFFECT_POPUP_WORD,"Kekkai Effect"])
      end      
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Bounded Slip MP
  #--------------------------------------------------------------------------                
  def execute_bounded_slip_mp
      return if bounded_effect[1] != 11
      return if self.mp == 0
      dmg = self.mmp * MOG_KEKKAI::SLIP_DAMAGE_PERC  / 100
      self.mp -= dmg 
      if $imported[:mog_damage_popup] != nil and MOG_KEKKAI::EFFECT_POPUP
         self.damage.push([dmg,"MP"])
         self.damage.push([MOG_KEKKAI::EFFECT_POPUP_WORD,"Kekkai Effect"])
      end      
  end  
  
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter

  #--------------------------------------------------------------------------
  # ● Bounded Effect
  #--------------------------------------------------------------------------        
  def bounded_effect 
      MOG_KEKKAI::BOUNDED_FIELD[$game_temp.kekkai[1]] rescue nil
  end     
  
  #--------------------------------------------------------------------------
  # ● Kekkai Effect
  #--------------------------------------------------------------------------    
  def kekkai_effect
      return if !SceneManager.scene_is?(Scene_Battle)
      return if bounded_effect == nil
      index = 0
      for i in $game_party.members
          break if index >= $game_party.max_battle_members
          i.hp = 1 if bounded_effect[1] == 4 and i.hp > 1
          i.mp = 0 if bounded_effect[1] == 5
          index += 1
      end  
  end
  
  #--------------------------------------------------------------------------
  # ● Command 311
  #--------------------------------------------------------------------------  
  alias mog_kekkai_command_311 command_311
  def command_311
      mog_kekkai_command_311
      kekkai_effect
  end
  
  #--------------------------------------------------------------------------
  # ● Command 312
  #--------------------------------------------------------------------------  
  alias mog_kekkai_command_312 command_312
  def command_312
      mog_kekkai_command_312
      kekkai_effect
  end  
  
  #--------------------------------------------------------------------------
  # ● Command 314
  #--------------------------------------------------------------------------  
  alias mog_kekkai_command_314 command_314
  def command_314
      mog_kekkai_command_314
      kekkai_effect
  end   
  
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------
  alias mog_kekkai_use_item use_item
  def use_item
      check_kekkai_effect
      mog_kekkai_use_item
  end
  
  #--------------------------------------------------------------------------
  # ● Check Kekkai Effect
  #--------------------------------------------------------------------------    
  def check_kekkai_effect
      return if @subject.is_a?(Game_Actor)
      skill = @subject.current_action.item
      if skill.note =~ /<Kekkai = (\d+)>/i 
         id = $1.to_i
         id = nil if id < 1
         $game_temp.kekkai = [true,id]
      end  
  end
    
end    

#==============================================================================
# ■ BattleManager
#==============================================================================
class << BattleManager
  
  #--------------------------------------------------------------------------
  # ● Init Members
  #--------------------------------------------------------------------------          
  alias mog_kekkai_init_members init_members
  def init_members
      $game_temp.battle_end = false
      mog_kekkai_init_members
  end  
  
  #--------------------------------------------------------------------------
  # ● Process Victory
  #--------------------------------------------------------------------------            
  alias mog_kekkai_process_victory process_victory 
  def process_victory 
      $game_temp.battle_end = true
      mog_kekkai_process_victory
  end
  
  #--------------------------------------------------------------------------
  # ● Process Abort
  #--------------------------------------------------------------------------            
  alias mog_kekkai_process_abort process_abort
  def process_abort
      $game_temp.battle_end = true
      mog_kekkai_process_abort
  end

  #--------------------------------------------------------------------------
  # ● Process Defeat
  #--------------------------------------------------------------------------            
  alias mog_kekkai_process_defeat process_defeat
  def process_defeat
      $game_temp.battle_end = true
      mog_kekkai_process_defeat
  end
  
end

#==============================================================================
# ■ Window Base
#==============================================================================
class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # ● Bounded Effect
  #--------------------------------------------------------------------------        
  def bounded_effect 
      MOG_KEKKAI::BOUNDED_FIELD[$game_temp.kekkai[1]] rescue nil
  end  
    
end

#==============================================================================
# ■ Window ActorCommand
#==============================================================================
class Window_ActorCommand < Window_Command
  
  #--------------------------------------------------------------------------
  # ● Make Command List
  #--------------------------------------------------------------------------          
  alias mog_kekkai_make_command_list make_command_list
  def make_command_list
      return if kekkai_enabled?
      mog_kekkai_make_command_list
  end  
    
  #--------------------------------------------------------------------------
  # ● Kekkai Enabled?
  #--------------------------------------------------------------------------          
  def kekkai_enabled?
      if bounded_effect != nil and (bounded_effect[1] == 8 or bounded_effect[1] == 9)
         if @actor != nil
            if bounded_effect[1] == 8
               add_attack_command
               add_item_command
            else
               add_guard_command 
            end
         end
         return true
      end
      return false 
  end  
  
end
