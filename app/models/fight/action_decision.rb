module Fight

  # This module is used by the algo to decide what action the unit will make.
  # The decision can be : movement, attack cac, attack melee
  #
  class ActionDecision

    def initialize( attacking_gang, defending_gang, attacking_unit, verbose: false )
      @attacking_gang = attacking_gang
      @defending_gang = defending_gang

      @attacking_unit = attacking_unit

      @verbose = verbose
    end

    def do_something

      log = nil
      @units_in_range = @defending_gang.units_in_range( @attacking_unit )
      nearest_enemy_unit = @defending_gang.nearest_enemy_unit( @attacking_unit )

      if @attacking_unit.exhausted?
        @attacking_unit.rest!

        puts "L'unité #{@attacking_unit.name} est fatiguée et se repose."

      elsif @attacking_unit.attack_range > 0 && @attacking_unit.distance( nearest_enemy_unit ) <= 2
        # If a ranged attacking unit is too close than another unit it will fall back.

        @attacking_unit.fall_back
        @attacking_unit.end_action

      elsif @attacking_unit.attack_range > 0 && @attacking_unit.attack_range >= @attacking_unit.distance( nearest_enemy_unit )
        # If a ranged attacking unit is close enough to attack at range.
        ranged_attack

      elsif @attacking_unit.attack_range == 0 && @attacking_unit.distance( nearest_enemy_unit ) == 0
        # If a cac attacking unit and has somebody to knock
        melee_attack

      else
        # In any other cases, we advance
        @attacking_unit.advance( nearest_enemy_unit.current_position )
        @attacking_unit.end_action
      end
    end

    def ranged_attack
      defending_unit = @units_in_range.sample

      puts "#{@attacking_unit.name} attaque #{defending_unit.name} à distance."

      ar = AttackWithRetaliation.new(
        @attacking_gang, @defending_gang, @attacking_unit, defending_unit, {},
        verbose: @verbose )

      ar.perform_ranged_attack!
      @attacking_unit.end_action
    end

    def melee_attack
      defending_unit = @units_in_range.sample

      puts "#{@attacking_unit.name} attaque #{defending_unit.name} au CAC."

      ar = AttackWithRetaliation.new(
        @attacking_gang, @defending_gang, @attacking_unit, defending_unit, {},
        verbose: @verbose )

      ar.perform_melee_attack!
      @attacking_unit.end_action
    end

  end
end