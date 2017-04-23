################vCookie_brainv################

class Scene_Battle < Scene_Base
  alias rearrange_invoke_item invoke_item
  def invoke_item(target, item)
    @subject.last_target_index = target.index
    rearrange_invoke_item(target, item)
  end
end

# Thanks to Shiggy the battle log messages doesn't go haywire

class Window_BattleLog < Window_Selectable
  def display_use_item(subject, item)
    if item.is_a?(RPG::Skill)
      return if item.note.include?("shiggy")
      add_text(subject.name + item.message1)
      unless item.message2.empty?
        wait
        add_text(item.message2)
      end
    else
      add_text(sprintf(Vocab::UseItem, subject.name, item.name))
    end
  end
  def display_action_results(target, item)
    if target.result.used
      if item.note.include?("cookie")
        last_line_number = line_number
        display_affected_status(target, item)
        display_failure(target, item)
        wait if line_number > last_line_number
        back_to(last_line_number)
      else
        return if item.note.include?("shiggy")
        last_line_number = line_number
        display_critical(target, item)
        display_damage(target, item)
        display_affected_status(target, item)
        display_failure(target, item)
        wait if line_number > last_line_number
        back_to(last_line_number)
      end
    end
  end
end

class Game_Battler < Game_BattlerBase
  attr_accessor :cookie
  def cookie_of_choice(skill_id, target)
    cookie = Game_Action.new(self, true)
    cookie.set_skill(skill_id)
    if target == 0
      cookie.target_index = last_target_index
    end
    @actions.push(cookie)
  end
end
################^Cookie_brain^################


class Game_Battler < Game_BattlerBase

  # We will write our AI(s) here

  def Subject_AI(a, b)

   # Here goes what we want it to do!

    if b.state?(30) == false
      return 138 #Toxin.


    elsif b.hp == 1
      return 138 #Toxin.

    else

      if rand(3) == 1
        return 45 #Curse Weapon.

      elsif rand(3) == 2 && b.hp <= 60
        return 1 #Attack

      else
        return 42 #Breath Armor.

      end

    end

  end

  def Warden_AI(a, b)

    if a.state?(4) == false

      if rand(4) == 1 && a.state?(27) == false
        return 131 #Stoneskin.

      elsif rand(4) == 2 && b.state?(4) == false
        return 148 #Silence.

      elsif rand(4) == 3
        return 72 #Dark AoE.

      else
        return 149 #Dark single target.

      end

    else
      return 1 #Regular attack.

    end

  end

  def Guardian_AI(a, b)

    if $game_troop.alive_members.length == 1
      return 156 #Beserk.

    elsif $game_troop.alive_members.length == 2
      return 134 #Wide Swing.

    else
      return 1 #Regular attack.

    end

  end

  def Rogue_AI(a, b)

    if $game_troop.alive_members.length == 1
      return 157 #Slash throat.

    elsif $game_troop.alive_members.length == 2

      if rand(2) == 1 && a.luk <= 46
        return 153 #Thief's Luck.

      else
        return 162 #Throw dagger.

      end

    else
      return 1 #Regular attack.

    end

  end

  def Sorcerer_AI(a, b)

    if $game_troop.alive_members.length == 1

      if b.state?(29) == false
        return 137 #Curse.

      elsif b.state(5) == false
        return 161 #Confusion.

      else
        return 51 #Fire.

      end

    elsif $game_troop.alive_members.length == 2 && b.state?(5) == false
      return 161 #Confusion.

    else
      return 51 #Fire.

    end

  end

  def Golem_AI(a, b)

    if $game_party.alive_members.length == 1
      return 167 #Golem Attack.

    else

      if rand(100) >= 40 && b.state?(8) == false && a.ap == 3
        return 168 #Shockwave.

      elsif rand(100) <= 15
        return 151 #Golem Wide Swing.

      else
        return 167 #Golem Attack.

      end

    end

  end

  def Trickster_AI(a, b)

    if $game_troop.alive_members.length > 1

      if a.ap == 9 && a.state?(4) == false
        return 172 #Dispel.  ||

      else
        n = rand(3)
        case n

        when 3
          return 173 #Strenghten.

        else
          return 1 #Attack.

        end
      end

    else

      if a.state?(4) == false

        return #EMP.

        return #Massive ATK buff.




      else

        return 112 #Thief's Luck.


      end

    end

  end

end
