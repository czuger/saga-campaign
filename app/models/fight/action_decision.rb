module Fight

  # This class is used by the algo to decide what action the unit will make.
  # The decision can be : movement, attack cac, attack melee
  #
  class ActionDecision

    def self.do_something( next_attacking_unit, defender_gang )

      uir = defender_gang.units_in_range( next_attacking_unit )

      unless uir.empty?
        unit_to_attack = uir.sample

        if next_attacking_unit.distance( unit_to_attack ) == 0
          puts "#{next_attacking_unit.name} attaque #{unit_to_attack.name} au CAC."
          next_attacking_unit.end_action
        else
          puts "#{next_attacking_unit.name} attaque #{unit_to_attack.name} à distance."
          next_attacking_unit.end_action
        end

      else
        # If no units are in range, then we advance
        nearest_unit_position = defender_gang.nearest_enemy_position( next_attacking_unit )
        next_attacking_unit.advance( nearest_unit_position )
        next_attacking_unit.end_action
      end

    end
  end
end
