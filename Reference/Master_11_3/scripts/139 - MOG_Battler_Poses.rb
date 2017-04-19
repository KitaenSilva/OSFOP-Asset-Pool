#==============================================================================
# +++ MOG - Battler Poses (v1.2) +++
#==============================================================================
# By Moghunter 
# https://atelierrgss.wordpress.com/
#==============================================================================
#  O script implementa o sistema de poses básicas para os battlers.
#  (Normal, Feliz, Ação, Dor)
#==============================================================================
# * UTILIZAÇÃO
#==============================================================================
# Serão necessários 2 arquivos de imagens do battler.
# 1 - Imagem utilizada no Database.
# 2 - Imagem usada na Batalha, divididos em 4 frames (Poses) do battler.
#
# EXEMPLO 
# Basta adicionar o sufixo [Poses] no arquivo que será usado na batalha
# e o script vai ativar automaticamente o sistema de poses para 
# este battler.
#
# 1 - Slime.png
# 2 - Slime[Poses].png
#
#==============================================================================

#==============================================================================
# v1.2 - Melhoria na compatibilidade com MOG Srite Actor.
# v1.1 - Melhoria na compatibilidade de scripts.
#==============================================================================

$imported = {} if $imported.nil?
$imported[:mog_battler_poses] = true

#==============================================================================
# ** Game_Battler
#==============================================================================
class Game_Battler < Game_BattlerBase
  
  attr_accessor :battler_pose
  
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  alias mog_battler_poses_gb_initialize initialize
  def initialize
      @battler_pose = [false,0,0,0]
      mog_battler_poses_gb_initialize
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Damage
  #--------------------------------------------------------------------------  
  alias mog_battler_pose_execute_damage execute_damage
  def execute_damage(user)
      mog_battler_pose_execute_damage(user)
      execute_battler_pose_damage(user)
  end
  
  #--------------------------------------------------------------------------
  # ● Execute Battler Pose Damage
  #--------------------------------------------------------------------------  
  def execute_battler_pose_damage(user)
      if @result.hp_damage > 0
         self.battler_pose[2] = 3
         self.battler_pose[1] = 50
      elsif @result.hp_damage < 0
         self.battler_pose[2] = 1
         self.battler_pose[1] = 50      
      end    
  end
  
end

#==============================================================================
# ■ Game Action
#==============================================================================
class Game_Action
  
  #--------------------------------------------------------------------------
  # ● Prepare
  #--------------------------------------------------------------------------                  
  alias mog_battler_pose_prepare prepare
  def prepare
      mog_battler_pose_prepare
      set_battler_pose_action
  end
    
  #--------------------------------------------------------------------------
  # ● Set Battler Pose Action
  #--------------------------------------------------------------------------                    
  def set_battler_pose_action
      return if @item.object == nil or subject == nil      
      subject.battler_pose[2] = 2
      subject.battler_pose[1] = 800
  end
  
end

#==============================================================================
# ■ Scene Battle
#==============================================================================
class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # ● Show Animation
  #--------------------------------------------------------------------------                    
  alias mog_battler_pose_show_animation show_animation
  def show_animation(targets, animation_id)
      mog_battler_pose_show_animation(targets, animation_id)
      clear_battler_pose(targets)
  end

  #--------------------------------------------------------------------------
  # ● Clear Battler Pose
  #--------------------------------------------------------------------------                    
  def clear_battler_pose(targets)
      return if @subject == nil
      return if @subject.battler_pose[2] != 2
      @subject.battler_pose[1] = 5      
  end
  
end

#==============================================================================
# ** Sprite_Battler
#==============================================================================
class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # * Initialize
  #--------------------------------------------------------------------------
  alias mog_battler_poses_initialize initialize
  def initialize(viewport, battler = nil)
      mog_battler_poses_initialize(viewport, battler)
      check_battler_poses
  end
 
  #--------------------------------------------------------------------------
  # * Check Battler Poses
  #--------------------------------------------------------------------------
  def check_battler_poses
      return if @battler == nil
      @cache_bitmap = nil
      @battler_visble = [0,0]
      @battler_id_old = -1
      @battler.battler_pose = [false,0,0,-1]
      @battler.battler_pose[0] = battler_poses_exist? ? true : false
  end
  
  #--------------------------------------------------------------------------
  # * Battler Pose Name
  #--------------------------------------------------------------------------
  def battler_pose_name
      @battler.battler_name + "[Poses]"
  end
      
  #--------------------------------------------------------------------------
  # ● Battler Poses Exist?
  #--------------------------------------------------------------------------
  def battler_poses_exist?
      Cache.battler(battler_pose_name, @battler.battler_hue) rescue return false
  end 
    
  #--------------------------------------------------------------------------
  # * Update Bitmap
  #--------------------------------------------------------------------------
  alias mog_battler_poses_update_bitmap update_bitmap
  def update_bitmap
      return if can_update_bitmap_battler_pose?
      mog_battler_poses_update_bitmap    
  end
  
  #--------------------------------------------------------------------------
  # * Can Update Bitmap Battler Pose
  #--------------------------------------------------------------------------
  def can_update_bitmap_battler_pose?
      return false if @battler == nil 
      return false if !@battler.battler_pose[0]      
      update_bitmap_battler_pose
      return true
  end
  
  #--------------------------------------------------------------------------
  # * Update Bitmap Battler Pose
  #--------------------------------------------------------------------------
  def update_bitmap_battler_pose
      return if $imported[:mog_battler_motion] and @battler.motion_slice[0]
      refresh_bitmap_battler_pose
      update_battler_pose_duration
      if $imported[:mog_sprite_actor]
         self.visible = @battler.bact_sprite_visiblle unless @battler.dead?
      end
      refresh_battler_pose if can_refresh_battler_pose?
  end

  #--------------------------------------------------------------------------
  # * Refresh Bitmap Battler Pose
  #--------------------------------------------------------------------------
  def refresh_bitmap_battler_pose
      return if @battler_id_old == @battler.enemy_id
      return if $imported[:mog_battler_motion] and @battler.motion_slice[0]
      check_battler_poses
      @battler_id_old = @battler.enemy_id         
      if @battler.battler_pose[0]            
          create_bitmap_battler_pose
      else
         self.bitmap = Cache.battler(@battler.battler_name, @battler.battler_hue)
      end   
      init_visibility
  end
      
  #--------------------------------------------------------------------------
  # * Update Battler Pose Duration
  #--------------------------------------------------------------------------
  def update_battler_pose_duration 
      return if @battler.battler_pose[1] == 0
      @battler.battler_pose[1] -=1
      return if @battler.battler_pose[1] > 0
      hp_low = @battler.mhp * 30 / 100
      @battler.battler_pose[2] = @battler.hp > hp_low ? 0 : 3
      refresh_battler_pose if @battler.battler_pose[1] == 0
  end
  
  #--------------------------------------------------------------------------
  # * Create Bitmap Battler Pose
  #--------------------------------------------------------------------------
  def create_bitmap_battler_pose
      return false if !@battler.battler_pose[0]
      @cache_bitmap = Cache.battler(battler_pose_name, @battler.battler_hue)
      @bp_cw = @cache_bitmap.width / 4
      @bp_ch = @cache_bitmap.height
      self.bitmap.dispose if self.bitmap != nil
      self.bitmap = Bitmap.new(@bp_cw,@bp_ch)
  end      
    
  #--------------------------------------------------------------------------
  # * Can Refresh Battler Pose
  #--------------------------------------------------------------------------
  def can_refresh_battler_pose?
      return false if @battler == nil
      return false if !@battler.battler_pose[0]
      return false if @battler.battler_pose[2] == @battler.battler_pose[3]
      return false if self.bitmap == nil
      return false if self.opacity == 0
      return false if $imported[:mog_battler_motion] and @battler.motion_slice[0]
      return true
  end

  #--------------------------------------------------------------------------
  # * Refresh Battler Pose
  #--------------------------------------------------------------------------
  def refresh_battler_pose
      @battler.battler_pose[3] = @battler.battler_pose[2]
      self.bitmap.clear rescue nil
      bp_rect = Rect.new(@bp_cw * @battler.battler_pose[2],0,@bp_cw,@bp_ch)
      self.bitmap.blt(0,0,@cache_bitmap,bp_rect)   
  end
  
end
