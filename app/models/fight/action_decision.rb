module Fight

  # This module is used by the algo to decide what action the unit will make.
  # The decision can be : movement, attack cac, attack melee
  #
  class ActionDecision

    def self.do_something( attacking_gang, defending_gang, attacking_unit )

      uir = defending_gang.units_in_range( attacking_unit )

      unless uir.empty?
        defending_unit = uir.sample

        if attacking_unit.distance( defending_unit ) == 0
          puts "#{attacking_unit.name} attaque #{defending_unit.name} au CAC."
          attacking_unit.end_action

        else
          puts "#{attacking_unit.name} attaque #{defending_unit.name} à distance."
          ar = AttackWithRetaliation.new( attacking_gang, defending_gang, attacking_unit, defending_unit, { } )
          ar.perform_ranged_attack!
          attacking_unit.end_action

        end
      else
        # If no units are in range, then we advance
        nearest_unit_position = defending_gang.nearest_enemy_position( attacking_unit )
        attacking_unit.advance( nearest_unit_position )
        attacking_unit.end_action

      end

    end
  end
end
