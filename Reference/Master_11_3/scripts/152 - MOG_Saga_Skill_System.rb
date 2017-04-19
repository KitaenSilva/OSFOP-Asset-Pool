#==============================================================================
# +++ MOG - Saga Skill System (v1.0) +++
#==============================================================================
# By Moghunter
# https://atelierrgss.wordpress.com/
#==============================================================================
# O script ativa o sistema de nível e exp dos atributos resultando em
# maior dano na medida que o nível é avançado.
# O sistema também adiciona o sistema de aprendizagem semi aleatório de 
# habilidades quando o requerimento do nível do atributo é alcançado.
# Este sistema é baseado no jogo Romancing Saga.
#==============================================================================
# NOTA - É necessário que o personagem tenha o tipo de comando da habilidade
#        ativado para que a habilidade seja aprendida.
#        EX - O personagem não vai aprender as habilidades de magia se o 
#        personagem não tiver o comando de magia ativado.
#==============================================================================

#==============================================================================
# ● COMMANDO DE AUMENTAR O LEVEL MANUALMENTE.
#==============================================================================
# Para aumentar o level do atributo use o comando abaixo.
#
# element_lv_up(ACTOR_ID , ATTRIBUTE_ID, VALUE)
# 
# element_lv_up(2,5,1)
#==============================================================================
# Para aumentar o level do tipo de arma use o comando abaixo.
#
# weapon_lv_up(ACTOR_ID , ATTRIBUTE_ID, VALUE)
# 
# weapon_lv_up(2,5,1)
#==============================================================================

#==============================================================================
# ● COMMANDO DE AUMENTAR A EXP MANUALMENTE.
#==============================================================================
# Para aumentar a experiência do atributo use o comando abaixo.
#
# element_exp_up(ACTOR_ID , ATTRIBUTE_ID, VALUE)
# 
# element_exp_up(2,5,20)
#==============================================================================
# Para aumentar a experiência do tipo de arma use o comando abaixo.
#
# weapon_exp_up(ACTOR_ID , ATTRIBUTE_ID, VALUE)
# 
# weapon_exp_up(2,5,20)
#==============================================================================

module MOG_SAGA_SKILL
  #----------------------------------------------------------------------------
  # Ativar o sistema de aprendizagem de habilidade.
  #----------------------------------------------------------------------------
  ENABLE_SKILL_LEARNING = true
  #----------------------------------------------------------------------------
  # Definição da % de change de aprender a habilidade ao atingir o nível 
  # necessário, essa porcentagem é subtraída pela diferença do level
  # do atributo, ou seja, quando maior o level do elemento maior será a
  # chance de aprender a habilidade.
  #----------------------------------------------------------------------------
  SUCCESS_RATE = 20
  #----------------------------------------------------------------------------
  # Definição da animação ao aprender a habilidade.
  #----------------------------------------------------------------------------
  LEARNING_ANIMATION_ID = 147
  #----------------------------------------------------------------------------
  # Definição do texto da janela de Log.
  #----------------------------------------------------------------------------
  BATTLE_LOG_TEXT = "learns"
  #----------------------------------------------------------------------------
  #Definição das habilidade que serão aprendidas. Referente aos elementos.
  #
  # ELEMENT_LEARN_SKILL[ A ] = {B => C, B => C, B=> C, ...}
  # 
  # A - ID do elemento.
  # B - ID da Habilidade.
  # C - Nivel mínimo necessário para aprender a habilidade.
  #----------------------------------------------------------------------------
  ELEMENT_LEARN_SKILL = []
  ELEMENT_LEARN_SKILL[1] = {100=>5, 105=>10, 106=>15} #Bare Hands(Physical)
  ELEMENT_LEARN_SKILL[2] = {26=>4 ,27=>12 , 28=>20, 29=>8,#Restoration(Absorb) 
                            30=>24 ,31=>6, 32=>14, 33=>10, 34=>26}
  ELEMENT_LEARN_SKILL[3] = {51=>4 ,52=>15 ,52=>8 ,53=>25 ,41=>6} #Fire  
  ELEMENT_LEARN_SKILL[4] = {55=>4 ,56=>15 ,57=>8 ,58=>25 ,26=>6} #Ice
  ELEMENT_LEARN_SKILL[5] = {59=>4 ,60=>15 ,61=>8 ,62=>25 ,40=>6} #Thunder
  ELEMENT_LEARN_SKILL[6] = {63=>4, 64 =>20 , 44=>10}  #Water
  ELEMENT_LEARN_SKILL[7] = {65=>4, 66 =>20 , 39=>10}  #Earth
  ELEMENT_LEARN_SKILL[8] = {67=>4, 68 =>20 , 35=>10}  #Wind
  ELEMENT_LEARN_SKILL[9] = {69=>4, 70 =>20 , 49=>10}  #Holy
  ELEMENT_LEARN_SKILL[10] = {71=>4, 72 =>20 , 47=>10} #Dark
  #----------------------------------------------------------------------------
  #Definição das habilidade que serão aprendidas. Referente aos tipos de armas.
  #
  # WEAPON_LEARN_SKILL[ A ] = {B => C, B => C, B=> C, ...}
  #
  # A - ID do elemento
  # B - ID da Habilidade(Skill)
  # C - Nivel mínimo necessário para aprender a habilidade.
  #----------------------------------------------------------------------------
  WEAPON_LEARN_SKILL = [] 
  WEAPON_LEARN_SKILL[1] = {84=>10 , 84=> 25}   #Axe
  WEAPON_LEARN_SKILL[2] = {88=>10 , 89=> 25}   #Claw
  WEAPON_LEARN_SKILL[3] = {93=>10 , 94=> 25}   #Spear
  WEAPON_LEARN_SKILL[4] = {95=>10 , 99=> 25}   #Sword
  WEAPON_LEARN_SKILL[5] = {100=>10 , 102=> 15, 103=> 25} #Katana
  WEAPON_LEARN_SKILL[6] = {108=>10 , 109=> 25} #Bow
  WEAPON_LEARN_SKILL[7] = {113=>10 , 114=> 25} #Dagger
  WEAPON_LEARN_SKILL[8] = {80=>5 , 81=> 10}    #Gun
  #----------------------------------------------------------------------------
  #Definição das habilidade que não serão aprendidas pelos personagens
  #
  # ACTOR_NOT_LEARN_SKILL_ID[ACTOR_ID] = [SKILL_ID1,SKILL_ID2,SKILL_ID3 ...]
  #----------------------------------------------------------------------------
  ACTOR_NOT_LEARN_SKILL_ID = []
  #ACTOR_NOT_LEARN_SKILL_ID[1] = [26,27,28,29,30]
  #ACTOR_NOT_LEARN_SKILL_ID[2] = [100,110]
end
#==============================================================================
# ● ATTRIBUTE LEVEL
#==============================================================================
module MOG_ATTRIBUTE_LEVEL
  #----------------------------------------------------------------------------
  #Definição dos elementos ignorados pelo sistema.
  #
  # DISABLE_ELEMENT_ID = [2,5,8]
  #
  #----------------------------------------------------------------------------
  DISABLE_ELEMENT_ID = []
  #----------------------------------------------------------------------------
  #Definição dos tipos de armas ignorados pelo sistema.
  #----------------------------------------------------------------------------
  DISABLE_WEAPON_ID = []
  #----------------------------------------------------------------------------
  #Definição do elemento de ataques sem armas.
  #Esse é ativado quando o personagem ataca sem armas.
  #----------------------------------------------------------------------------
  BARE_HANDS_ELEMENT_ID = 1
  #----------------------------------------------------------------------------
  #Definição da exp necessária para atingir o próximo nível. (level x valor)
  #----------------------------------------------------------------------------
  NEXT_EXP_LEVEL_BASE = 5
  #----------------------------------------------------------------------------
  #Definição do level maximo.
  #----------------------------------------------------------------------------
  MAX_ATTRIBUTE_LEVEL = 100
  #----------------------------------------------------------------------------
  #Definição da porcentagem de dano a cada level.
  #----------------------------------------------------------------------------
  DAMAGE_PERCENTAGE_PER_LEVEL = 5
  #----------------------------------------------------------------------------
  #Nome da janela de atributo.
  #----------------------------------------------------------------------------
  ATTRIBUTE_LEVEL_NAME = "Attribute Level"
  #----------------------------------------------------------------------------
  #Definição do texto da janela de ajuda.
  #----------------------------------------------------------------------------
  PRESS_BUTTON_TEXT = "(C Button) Attribute Status"
end

$imported = {} if $imported.nil?
$imported[:mog_saga_skill_system] = true

#==============================================================================
# ■ Game Interpreter
#==============================================================================
class Game_Interpreter

  #--------------------------------------------------------------------------
  # ● Element LV
  #--------------------------------------------------------------------------
  def element_lv_up(actor_id,atr_id,value)
      return if atr_id < 0
      return if MOG_ATTRIBUTE_LEVEL::DISABLE_ELEMENT_ID.include?(atr_id)
      $game_party.members.each do |actor|
      if actor.id == actor_id and ![nil,""].include?(actor.attribute_level[0][atr_id][5])
         actor.attribute_level[0][atr_id][0] += value
         actor.attribute_level[0][atr_id][0] = 1 if actor.attribute_level[0][atr_id][0] < 0
         actor.attribute_level[0][atr_id][0] = MOG_ATTRIBUTE_LEVEL::MAX_ATTRIBUTE_LEVEL if actor.attribute_level[0][atr_id][0] > MOG_ATTRIBUTE_LEVEL::MAX_ATTRIBUTE_LEVEL
         actor.attribute_level[0][atr_id][1] = 0
      end
      end    
  end

  #--------------------------------------------------------------------------
  # ● Element EXP
  #--------------------------------------------------------------------------
  def element_exp_up(actor_id,atr_id,value)
      return if atr_id < 0
      return if MOG_ATTRIBUTE_LEVEL::DISABLE_ELEMENT_ID.include?(atr_id)
      $game_party.members.each do |actor|
      if actor.id == actor_id and ![nil,""].include?(actor.attribute_level[0][atr_id][5])
         actor.attribute_level[0][atr_id][1] += value.abs
         element_lv_up(actor_id,atr_id,1) if actor.atr_level_up?(atr_id,0)
      end
      end    
  end  
  
  #--------------------------------------------------------------------------
  # ● Weapon LV
  #--------------------------------------------------------------------------
  def weapon_lv_up(actor_id,atr_id,value)
      return if atr_id < 0
      return if MOG_ATTRIBUTE_LEVEL::DISABLE_WEAPON_ID.include?(atr_id)
      $game_party.members.each do |actor|
      if actor.id == actor_id and ![nil,""].include?(actor.attribute_level[1][atr_id][5])
         actor.attribute_level[1][atr_id][0] += value
         actor.attribute_level[1][atr_id][0] = 1 if actor.attribute_level[1][atr_id][0] < 0
         actor.attribute_level[1][atr_id][0] = MOG_ATTRIBUTE_LEVEL::MAX_ATTRIBUTE_LEVEL if actor.attribute_level[1][atr_id][0] > MOG_ATTRIBUTE_LEVEL::MAX_ATTRIBUTE_LEVEL
         actor.attribute_level[1][atr_id][1] = 0
      end
      end       
  end
  
  #--------------------------------------------------------------------------
  # ● Weapon LV
  #--------------------------------------------------------------------------
  def weapon_exp_up(actor_id,atr_id,value)
      return if atr_id < 0
      return if MOG_ATTRIBUTE_LEVEL::DISABLE_WEAPON_ID.include?(atr_id)
      $game_party.members.each do |actor|
      if actor.id == actor_id and ![nil,""].include?(actor.attribute_level[1][atr_id][5])
         actor.attribute_level[1][atr_id][1] += value.abs
         weapon_lv_up(actor_id,atr_id,1) if actor.atr_level_up?(atr_id,1)
      end
      end       
  end  
  
end

#==============================================================================
# ■ Window_Status
#==============================================================================
class Window_Attribute_Level < Window_Selectable
  
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize(actor)
      super(0, 0, Graphics.width, Graphics.height)
      self.visible = false
      @actor = actor
      refresh
  end
 
  #--------------------------------------------------------------------------
  # ● Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
      return if @actor == actor
      @actor = actor
      refresh
  end
 
  #--------------------------------------------------------------------------
  # ● Actor Elements
  #--------------------------------------------------------------------------
  def actor_attributes
      atr = []
      for i in @actor.attribute_level[0]
          next if i == nil or i[5] == ""
          next if i[4] == MOG_ATTRIBUTE_LEVEL::BARE_HANDS_ELEMENT_ID
          next if MOG_ATTRIBUTE_LEVEL::DISABLE_ELEMENT_ID.include?(i[4])
          atr.push(i)
      end  
      atr.push(@actor.attribute_level[0][MOG_ATTRIBUTE_LEVEL::BARE_HANDS_ELEMENT_ID])
      for i in @actor.attribute_level[1]
          next if i == nil or i[5] == ""
          next if MOG_ATTRIBUTE_LEVEL::DISABLE_WEAPON_ID.include?(i[4])
          atr.push(i)
      end          
      return atr
   end
  
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    atrbutes = actor_attributes  
    sw = Graphics.width - 16 ; sh = Graphics.height - 80
    h_limit = sh / 32 ; x = 0 ; y = 48
    sp = atrbutes.size > h_limit * 2 ? 3 : 2 ; x_space = sw / sp
    change_color(normal_color)
    draw_text(0,0,sw,32,MOG_ATTRIBUTE_LEVEL::ATTRIBUTE_LEVEL_NAME.to_s, 1)
    draw_horz_line(line_height * 1)    
    atrbutes.each_with_index do |i, index|
        x2 = x_space * (index / h_limit)
        y2 = -((h_limit * 32) * (index / h_limit))
        change_color(normal_color)
        draw_text(x + x2,y + y2 + 32 * index,x_space - 64,32,i[5].to_s, 0)
        contents.font.color = Color.new(200,200,200,255)
        draw_text(x + x2 + x_space - 64,y + y2 + 32 * index,64,32,"LV".to_s, 0)
        draw_text(x + x2 + x_space - 74,y + y2 + 32 * index,64,32,i[0].to_s.to_s, 2)
        draw_gauge(x + x2, line_height - 12 + y + y2 + 32 * index, x_space - 64, i, tp_gauge_color1, tp_gauge_color2)
    end
  end

  #--------------------------------------------------------------------------
  # ● Draw Gauge
  #--------------------------------------------------------------------------
  def draw_gauge(x, y, width, atr, color1, color2)
      fill_w = width * atr[1] / @actor.atr_next_exp(atr[4],atr[6])
      fill_w = width if @actor.atr_max_level?(atr[4],atr[6])
      gauge_y = y + line_height - 8
      contents.fill_rect(x, gauge_y, width, 6, gauge_back_color)
      contents.gradient_fill_rect(x, gauge_y, fill_w, 6, color1, color2)
  end  
  
  #--------------------------------------------------------------------------
  # ● Draw Horizontal Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
      line_y = y + line_height / 2 - 1
      contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  
  #--------------------------------------------------------------------------
  # ● Line Color
  #--------------------------------------------------------------------------
  def line_color
      color = normal_color ; color.alpha = 48 ; color
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  def update
      super
      self.opacity = 255
  end
  
end

#==============================================================================
# ■ Window_Status
#==============================================================================
class Window_Attribute_Button < Window_Selectable
  attr_accessor :fade_time
  #--------------------------------------------------------------------------
  # ● Object Initialization
  #--------------------------------------------------------------------------
  def initialize
      super(0, 0, Graphics.width, 64)
      self.y = Graphics.height - self.height ; @fade_time = 60
      self.opacity = 0 ; self.contents_opacity = 0
      refresh
  end
 
  #--------------------------------------------------------------------------
  # ● Refresh
  #--------------------------------------------------------------------------
  def refresh
      contents.clear
      draw_text(0,0,self.width - 32,32,MOG_ATTRIBUTE_LEVEL::PRESS_BUTTON_TEXT.to_s,1)
  end

  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  def update
      super
      if @fade_time > 0
         @fade_time -= 1 ; self.opacity += 20 ; self.contents_opacity += 20
      else   
         if self.opacity > 0
            self.y += 5 ; self.opacity -= 5 ; self.contents_opacity -= 5  
         end
      end    
  end
  
end

#==============================================================================
# ■ Scene_Status
#==============================================================================
class Scene_Status < Scene_MenuBase
  
  #--------------------------------------------------------------------------
  # ● Start
  #--------------------------------------------------------------------------
  alias mog_atr_start start
  def start
      mog_atr_start 
      @attribute_window = Window_Attribute_Level.new(@actor)
      @attribute_window.z = @status_window.z + 50
      @attribute_Button_window = Window_Attribute_Button.new
      @attribute_Button_window.z = @attribute_window.z - 1
  end
  
  #--------------------------------------------------------------------------
  # ● On Actor Change
  #--------------------------------------------------------------------------
  alias mog_atr_on_actor_change on_actor_change
  def on_actor_change
      mog_atr_on_actor_change
      @attribute_window.actor = @actor      
  end
  
  #--------------------------------------------------------------------------
  # ● Update
  #--------------------------------------------------------------------------
  alias mog_atr_update update
  def update
      mog_atr_update
      if Input.trigger?(:C)
         Sound.play_ok ; @attribute_Button_window.fade_time = 0
         @attribute_window.visible = @attribute_window.visible ? false : true
      end
  end
  
end

#==============================================================================
# ■ Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  attr_accessor :attribute_level
  
  #--------------------------------------------------------------------------
  # ● Initialize
  #--------------------------------------------------------------------------
  alias mog_attribute_initialize initialize
  def initialize
      initial_attribute_level
      mog_attribute_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● Initial Attribute Level
  #--------------------------------------------------------------------------
  def initial_attribute_level
      @attribute_level = [[],[]]
      $data_system.elements.each_with_index do |i, index|
         @attribute_level[0].push([1,0,0,false,index,i,0])
      end
      $data_system.weapon_types.each_with_index do |i, index|
         @attribute_level[1].push([1,0,0,false,index,i,1])
      end
  end

  #--------------------------------------------------------------------------
  # ● Atr Clear EXP Phase
  #--------------------------------------------------------------------------
  def atr_clear_exp_phase
      @attribute_level[0].each do |i| ; i[3] = false ; end
      @attribute_level[1].each do |i| ; i[3] = false ; end
  end  
  
  #--------------------------------------------------------------------------
  # ● Atr Base EXP
  #--------------------------------------------------------------------------
  def atr_base_exp
      return 1
  end

  #--------------------------------------------------------------------------
  # ● Add Atr EXP
  #--------------------------------------------------------------------------
  def add_atr_exp(atr_id,type)
       return if !atr_exp?(atr_id,type)
       @attribute_level[type][atr_id][1] += atr_base_exp
       @attribute_level[type][atr_id][2] += atr_base_exp
       atr_level_up(atr_id,type) if atr_level_up?(atr_id,type)
  end

  #--------------------------------------------------------------------------
  # ● Atr EXP ?
  #--------------------------------------------------------------------------
  def atr_exp?(atr_id,type)
       return false if atr_id < 0
       return false if atr_max_level?(atr_id,type)       
       return false if @attribute_level[type][atr_id][3]
       return false if [nil,""].include?(@attribute_level[type][atr_id][5])       
       return false if type == 0 and MOG_ATTRIBUTE_LEVEL::DISABLE_ELEMENT_ID.include?(atr_id)
       return false if type == 1 and MOG_ATTRIBUTE_LEVEL::DISABLE_WEAPON_ID.include?(atr_id)
       return true
  end
  
  #--------------------------------------------------------------------------
  # ● Atr Level UP
  #--------------------------------------------------------------------------
  def atr_level_up?(atr_id,type)
      return false if atr_max_level?(atr_id,type)
      return true if @attribute_level[type][atr_id][1] >= atr_next_exp(atr_id,type)
      return false
  end

  #--------------------------------------------------------------------------
  # ● Atr Max Level
  #--------------------------------------------------------------------------
  def atr_max_level?(atr_id,type)
      return true if @attribute_level[type][atr_id][0] >= MOG_ATTRIBUTE_LEVEL::MAX_ATTRIBUTE_LEVEL
      return false
  end
  
  #--------------------------------------------------------------------------
  # ● Atr Level UP
  #--------------------------------------------------------------------------
  def atr_next_exp(atr_id,type)
      return @attribute_level[type][atr_id][0] * MOG_ATTRIBUTE_LEVEL::NEXT_EXP_LEVEL_BASE
  end

  #--------------------------------------------------------------------------
  # ● Atr Level UP
  #--------------------------------------------------------------------------
  def atr_level_up(atr_id,type)
      @attribute_level[type][atr_id][0] += 1
      @attribute_level[type][atr_id][1] = 0 unless atr_max_level?(atr_id,type)
  end

  #--------------------------------------------------------------------------
  # ● Make Atr Damage Value
  #--------------------------------------------------------------------------
  alias mog_atr_make_damage_value make_damage_value
  def make_damage_value(user, item)
      mog_atr_make_damage_value(user, item)
      if attribute_effect?(user, item)         
         make_atr_damage_value(user, item)
         excute_add_atr_exp(user, item)
         if $imported[:mog_atb_system] and coop_make_damage_value?(user, item)
            for actor in BattleManager.cskill_members(item.id)
                next if actor == user
                make_atr_damage_value(actor, item)
                excute_add_atr_exp(actor, item)
            end
         end
      end   
  end
  
  #--------------------------------------------------------------------------
  # ● Attribute Effect
  #--------------------------------------------------------------------------
  def attribute_effect?(user, item)
      return false if item == nil
      return false if item.is_a?(RPG::Item)
      return false if user.is_a?(Game_Enemy)
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Add Atr EXP
  #--------------------------------------------------------------------------
  def excute_add_atr_exp(user, item)
      if item.id == user.attack_skill_id
          if user.equips[0] != nil
             atr_id_1 = user.equips[0].wtype_id
             user.add_atr_exp(atr_id_1,1)
          else   
             user.add_atr_exp(MOG_ATTRIBUTE_LEVEL::BARE_HANDS_ELEMENT_ID,0)
             user.attribute_level[1][0][3] = true
          end
          if user.dual_wield? and user.equips[1] != nil
             atr_id_2 = user.equips[1].wtype_id
             user.add_atr_exp(atr_id_2,1)
          end
          user.attribute_level[1][atr_id_1][3] = true if atr_id_1 != nil
          user.attribute_level[1][atr_id_2][3] = true if atr_id_2 != nil
      else  
         user.add_atr_exp(item.damage.element_id,0)
         if user.equips[0] != nil and
            (item.required_wtype_id1 == user.equips[0].wtype_id or
            item.required_wtype_id2 == user.equips[0].wtype_id)         
            user.add_atr_exp(user.equips[0].wtype_id,1) ; wp_1 = true
         end
         if user.dual_wield? and user.equips[1] != nil and
            (item.required_wtype_id1 == user.equips[1].wtype_id or
            item.required_wtype_id2 == user.equips[1].wtype_id)
            user.add_atr_exp(user.equips[1].wtype_id,1) ; wp_2 = true
         end   
         user.attribute_level[0][item.damage.element_id][3] = true
         user.attribute_level[1][user.equips[0].wtype_id][3] = true if wp_1
         user.attribute_level[1][user.equips[1].wtype_id][3] = true if wp_2
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Atr Dmg P
  #--------------------------------------------------------------------------
  def atr_dmg_p(user,atr_id,type)
      ((user.attribute_level[type][atr_id][0] - 1)  * MOG_ATTRIBUTE_LEVEL::DAMAGE_PERCENTAGE_PER_LEVEL)
  end  
    
  #--------------------------------------------------------------------------
  # ● Make Atr Damage Value
  #--------------------------------------------------------------------------
  def make_atr_damage_value(user, item)
      b_damage = @result.hp_damage if item.damage.to_hp?
      b_damage = @result.mp_damage if item.damage.to_mp?
      b_damage = 0 if b_damage.nil?
      if item.id == user.attack_skill_id
         if user.equips[0] != nil
            atr_id = user.equips[0].wtype_id
            dam = b_damage * atr_dmg_p(user,atr_id,1) / 100
            execute_atr_damage(user,dam,item)
         else   
            dam = b_damage * atr_dmg_p(user,MOG_ATTRIBUTE_LEVEL::BARE_HANDS_ELEMENT_ID,0) / 100
            execute_atr_damage(user,dam,item)          
         end 
         if user.dual_wield? and user.equips[1] != nil
            atr_id = user.equips[1].wtype_id
            dam = b_damage * atr_dmg_p(user,atr_id,1) / 100
            execute_atr_damage(user,dam,item)
         end
      else
            dam = b_damage * atr_dmg_p(user,item.damage.element_id,0) / 100
            execute_atr_damage(user,dam,item)
            if user.equips[0] != nil and
               (item.required_wtype_id1 == user.equips[0].wtype_id or
                item.required_wtype_id2 == user.equips[0].wtype_id)
                atr_id = user.equips[0].wtype_id
                dam = b_damage * atr_dmg_p(user,atr_id,1) / 100
                execute_atr_damage(user,dam,item)
            end
            if user.dual_wield? and user.equips[1] != nil and
               (item.required_wtype_id1 == user.equips[1].wtype_id or
               item.required_wtype_id2 == user.equips[1].wtype_id)
               atr_id = user.equips[1].wtype_id
               dam = b_damage * atr_dmg_p(user,atr_id,1) / 100               
               execute_atr_damage(user,dam,item)
            end 
      end
  end
  
  #--------------------------------------------------------------------------
  # ● Execute ATR Damage
  #--------------------------------------------------------------------------
  def execute_atr_damage(user,b_damage,item)
      m_size = 1
      if $imported[:mog_atb_system] and coop_make_damage_value?(user, item)
          m_size = BattleManager.cskill_members(item.id).size if BattleManager.cskill_members(item.id).size > 0
      end        
      @result.hp_damage += (b_damage / m_size) if item.damage.to_hp?
      @result.mp_damage += (b_damage / m_size) if item.damage.to_mp?    
  end
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------
  alias mog_atr_level_use_item use_item
  def use_item
      mog_atr_level_use_item
      @subject.atr_clear_exp_phase
  end
  
end

#==============================================================================
# ■ Game Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  #--------------------------------------------------------------------------
  # ● Make Action
  #--------------------------------------------------------------------------
  def make_action_r(skill_id, target_index)  
      clear_actions
      action = Game_Action.new(self, true)
      action.set_skill(skill_id)
      action.target_index = target_index
      @actions.push(action)    
  end 
  
end

#==============================================================================
# ■ Game Actor
#==============================================================================
class Game_Actor < Game_Battler
  attr_reader   :actor_id
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Use Item
  #--------------------------------------------------------------------------
  alias mog_atr_level_execute_action execute_action
  def execute_action
      execute_random_learning if execute_random_learning?
      mog_atr_level_execute_action
  end

  #--------------------------------------------------------------------------
  # ● Execute Random Learning?
  #--------------------------------------------------------------------------
  def execute_random_learning?
      return false if !MOG_SAGA_SKILL::ENABLE_SKILL_LEARNING
      return false if @subject.nil?
      return false if @subject.is_a?(Game_Enemy)    
      item = @subject.current_action.item rescue nil
      return false if item == nil
      return false if item.is_a?(RPG::Item)
      return false if $imported[:mog_atb_system] and BattleManager.is_cskill?(item.id)
      return true
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Random Learning
  #--------------------------------------------------------------------------
  def execute_random_learning
      item = @subject.current_action.item ; success = false ; skill_id = 0 ; skill = nil
      if item.id ==  @subject.attack_skill_id
         if @subject.equips[0] != nil
            atr_id = @subject.equips[0].wtype_id ; type = 1
         else   
            atr_id = MOG_ATTRIBUTE_LEVEL::BARE_HANDS_ELEMENT_ID ; type = 0
         end  
         skill_list = MOG_SAGA_SKILL::ELEMENT_LEARN_SKILL[atr_id] if type == 0
         skill_list = MOG_SAGA_SKILL::WEAPON_LEARN_SKILL[atr_id] if type == 1
      else
         atr_id = item.damage.element_id ; type = 0
         skill_list = MOG_SAGA_SKILL::ELEMENT_LEARN_SKILL[atr_id]
      end
      if skill_list != nil ; skill_list.each do |i| ; skill_id = i[0]
         skill = $data_skills[skill_id]
         if atr_learn_skill?(skill,atr_id,i[1],type)
            success = true ; @subject.learn_skill(skill_id) ; break
         end
      end
      end
      if success and skill_id != 0
         target = @subject.current_action.target_index 
         @subject.make_action_r(skill_id, target)
         @log_window.display_learned_skill(@subject.name,skill.name)
         execute_learning_animation
      end
  end

  #--------------------------------------------------------------------------
  # ● Atr Learn Skill
  #--------------------------------------------------------------------------
  def atr_learn_skill?(skill,atr_id,lv_r,type)
      return false if skill == nil
      return false if $imported[:mog_atb_system] and BattleManager.is_cskill?(skill.id)
      nskill = MOG_SAGA_SKILL::ACTOR_NOT_LEARN_SKILL_ID[@subject.actor_id]
      return false if !nskill.nil? and nskill.include?(skill.id)
      return false if !@subject.added_skill_types.include?(skill.stype_id)
      return false if @subject.skill_learn?(skill)
      return false if @subject.attribute_level[type][atr_id][0] < lv_r
      success_rate = MOG_SAGA_SKILL::SUCCESS_RATE + (@subject.attribute_level[type][atr_id][0] - lv_r).abs
      return false if success_rate < rand(100)
      return true
  end

  #--------------------------------------------------------------------------
  # ● Execute Learning Animation
  #--------------------------------------------------------------------------
  def execute_learning_animation
      @subject.animation_id = MOG_SAGA_SKILL::LEARNING_ANIMATION_ID
      return if @subject.animation_id.nil? or @subject.animation_id < 1
      animation = $data_animations[@subject.animation_id] rescue nil
      return if animation.nil?
      anid = (animation.frame_max * 4) + 1 ; anid.times do ; update_basic ; end
  end
  
end

#==============================================================================
# ■ Window BattleLog
#==============================================================================
class Window_BattleLog < Window_Selectable
  
  #--------------------------------------------------------------------------
  # ● Display Learned Skill
  #--------------------------------------------------------------------------
  def display_learned_skill(battler_name,skill_name)
      text = battler_name.to_s + " " + MOG_SAGA_SKILL::BATTLE_LOG_TEXT + " " + skill_name.to_s + "!"
      replace_text(text) ; wait
  end

end