#===============================================================================
# Enemy AI : Targeting Priority Manipulator
#   by Shad3Light
#
# 2014/03/20
# Link: http://shad3light.blogspot.com/2014/03/enemy-ai-targeting-priority-manipulator.html
#===============================================================================


=begin
================================================================================
Description

The default VX Ace's enemy targeting behavior just pick a random target for
any actions.
This script adds some AI targeting priority. With this script, the enemies
become able to pick a target based on the action specific priority.

--------------------------------------------------------------------------------
History

v1.0 (2014/03/20)
  Initial release

--------------------------------------------------------------------------------
Terms of Use

- You are free to use this script for non-commercial projects.
- For commercial projects, at least contact me first.
- This script is provided as-is. Don't expect me to give support.
- Reported bug will be fixed, but no guarantee on requested features.
- No guarantee either for compatibility fixes.
- Give credit to Shad3Light (me), and do not delete this header.
--------------------------------------------------------------------------------
Installation

Put this script below Бе Materials and above Бе Main Process.
If there are scripts that overwrite the aliased methods below,
put this script below said script.
--------------------------------------------------------------------------------
Usage

In an enemy notebox, you can add some tags.
  <target [action_id] [shortcut]>
where [action_id] corresponds to the enemy's action list, and [shortcut]
corresponds to one of the implemented targeting priority method.

Example:
  <target 1 high_hp>
This will make the enemy target the battlers with the highest HP value when
using action number 1 (by default Attack).

  <target 2 low_hp_rate>
This will make the enemy target the battler with the lowest HP percentage when
using action number 2. If the action no. 2 is set to Heal, the enemy will
proceed to heal its ally with the lowest percentage of health.

Available targeting shortcut is as follows:
  low_hp
  high_hp
  low_hp_rate
  high_hp_rate
  low_mp
  high_mp
  low_mp_rate
  high_mp_rate
  low_tp
  high_tp
  low_tp_rate
  high_tp_rate
  self
  not_self

If you want to make your own targeting condition, use
  <target eval [action_id]>
  [eval]
  </target eval>
where [eval] is a ruby expression that takes returns -1, 0, or 1.
In the eval, a and b denotes the battlers that would be sorted.

For example, to make the enemy prioritize Eric when doing its ultimate skill,
the tag will be
  <target eval 8>
  if a.name == "Eric"
    -1
  elsif b.name == "Eric"
    1
  else
    a.hp <=> b.hp
  end
  </target eval>


Do note that target selection is done at the start of the turn, like actors.
The enemy will not suddenly change target mid-turn, for example if its target
had already healed.
Also, TGR have no effect on acquiring target.
================================================================================
=end

if $imported && $imported[:SHD_TargetingManipulator]
  msgbox "Warning: Targeting Priority Manipulator script is imported twice."
else

  $imported = {} if $imported.nil?
  $imported[:SHD_TargetingManipulator] = true

#===============================================================================
# Configuration Module
#
# None.
#
# Configuration Module End
#===============================================================================

#===============================================================================
# Code Start
#   Configuration ends here. Edit what's below at your own risk.
#-------------------------------------------------------------------------------
# Aliased methods:
#   DataManager
#     self.load_database
#   Game_Action
#     set_enemy_action
#
# New methods:
#   DataManager
#     self.load_notetags_adv_ai_target
#   RPG::Enemy
#     load_notetags_adv_ai_target
#   RPG::Enemy::Action
#     targeting_shortcut (attr_reader)
#     targeting_shortcut=
#     targeting_eval (attr_reader)
#     targeting_eval=
#     use_adv_targeting?
#   Game_Action
#     set_ai_target
#     set_ai_opponent_target
#     set_ai_friend_target
#     ai_sorting
#     ai_sorting_extension
#===============================================================================

#-------------------------------------------------------------------------------
# Module SHD
# Mainly contains Regular Expressions.
#
  module SHD

    module REGEXP
      ENEMY_TARG_EVAL = /<targ(?:et){,1}?[-_ ]?eval[: ]+(\d+)[ ]*>(.*?)<\/targ(:?et){,1}?[-_ ]?eval>/im
      ENEMY_TARG_SHORTCUT = /<targ(?:et){,1}?[: ]+(\d+)[, ]+(\w+)>/i
    end

  end
#
# End Module SHD
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Module DataManager
# Adding methods for reading enemy notetags.
#
  module DataManager

    class <<self
      alias :load_database_adv_ai_target :load_database
    end

    def self.load_database
      load_database_adv_ai_target
      load_notetags_adv_ai_target
    end

    def self.load_notetags_adv_ai_target
      $data_enemies.each do |o|
        next if o.nil?
        o.load_notetags_adv_ai_target
      end
    end

  end
#
# End Module DataManager
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Class RPG::Enemy
#
  class RPG::Enemy < RPG::BaseItem

    def load_notetags_adv_ai_target
      self.note.split(/[\r\n]+/).each { |line|
        if line =~ SHD::REGEXP::ENEMY_TARG_SHORTCUT
          action_id = $1.to_i - 1
          if @actions[action_id]
            @actions[action_id].targeting_shortcut = $2.downcase.to_sym
          end
        end
      }
      self.note.scan(SHD::REGEXP::ENEMY_TARG_EVAL).each { |match|
        action_id = match[0].to_i - 1
        if @actions[action_id]
          @actions[action_id].targeting_eval = match[1]
        end
      }
    end

  end
#
# End Class RPG::Enemy
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Class RPG::Enemy::Action
#
  class RPG::Enemy::Action

    attr_reader :targeting_shortcut
    attr_reader :targeting_eval

    def use_adv_targeting?
      @use_adv_targeting
    end

    def targeting_shortcut=(symbol)
      @targeting_shortcut = symbol
      @use_adv_targeting = true
    end

    def targeting_eval=(string)
      @targeting_shortcut = :eval
      @targeting_eval = string
      @use_adv_targeting = true
    end

  end
#
# End Class RPG::Enemy::Action
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Class Game_Action
#
  class Game_Action

    #-----------------------------------------------------------------------------
    # Alias Method: set_enemy_action
    #
    alias :set_enemy_action_ai_prio :set_enemy_action
    def set_enemy_action(action)
      set_enemy_action_ai_prio(action)
      set_ai_target(action) if action
    end

    #-----------------------------------------------------------------------------
    # New Method: set_ai_target
    #
    def set_ai_target(action)
      return unless action.use_adv_targeting?
      if item.for_opponent?
        set_ai_opponent_target(action)
      elsif item.for_friend?
        set_ai_friend_target(action)
      end
    end

    #-----------------------------------------------------------------------------
    # New Method: set_ai_opponent_target
    #
    def set_ai_opponent_target(action)
      candidates = opponents_unit.alive_members
      candidates.sort! { |a, b| ai_sorting(a, b, action) }
      @target_index = candidates[0].index
    end

    #-----------------------------------------------------------------------------
    # New Method: set_ai_friend_target
    #
    def set_ai_friend_target(action)
      if item.for_dead_friend?
        candidates = friends_unit.dead_members
      else
        candidates = friends_unit.alive_members
      end
      candidates.sort! { |a, b| ai_sorting(a, b, action) }
      @target_index = candidates[0].index
    end

    #-----------------------------------------------------------------------------
    # New Method: ai_sorting
    #
    def ai_sorting(a, b, action)
      case action.targeting_shortcut

      when :low_hp
        return a.hp <=> b.hp

      when :high_hp
        return b.hp <=> a.hp

      when :low_hp_rate
        return a.hp_rate <=> b.hp_rate

      when :high_hp_rate
        return b.hp_rate <=> a.hp_rate

      when :low_mp
        return a.mp <=> b.mp

      when :high_mp
        return b.mp <=> a.mp

      when :low_mp_rate
        return a.mp_rate <=> b.mp_rate

      when :high_mp_rate
        return b.mp_rate <=> a.mp_rate

      when :low_tp
        return a.tp <=> b.tp

      when :high_tp
        return b.tp <=> a.tp

      when :low_tp_rate
        return a.tp_rate <=> b.tp_rate

      when :high_tp_rate
        return b.tp_rate <=> a.tp_rate

      when :self
        return a == subject ? -1 : rand(2)

      when :not_self
        return a != subject ? rand(2) - 1 : 1

      when :eval
        return eval(action.targeting_eval)

      else
        return ai_sorting_extension(a, b, action)

      end
    end

    #-----------------------------------------------------------------------------
    # New Method: ai_sorting_extension
    # To be aliased by script extensions.
    #
    def ai_sorting_extension(a, b, action)
      return 0
    end

  end
#
# End Class Game_Action
#-------------------------------------------------------------------------------

end #if $imported
