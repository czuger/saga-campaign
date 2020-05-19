module GameRules

  # This class differs from the Fight class. This is only the computation according to the rules.
  # The Fight module is for algo resolved fights only. It should use this class to handle fight results.
  class CombatResult

    def initialize( movement_result )
      @movement_result = movement_result
      @attacking_gang = movement_result.gant
      @defending_gang = movement_result.intercepted_gang
    end

    def recover_units
      sub_recover_units @attacking_gang
      sub_recover_units @defending_gang
    end

    def determine_result
      @attacker_points_list, @attacker_points_total = compute_result_for @defending_gang
      @defender_points_list, @defender_points_total = compute_result_for @attacking_gang

      if @attacker_points_total >= 8 && @attacker_points_total > @defender_points_total + 3

        @winner = @attacker_name
        @winner_code = :attacker

      elsif @defender_points_total >= 8 && @defender_points_total > @attacker_points_total + 3

        @winner = @defender_name
        @winner_code = :defender

      else

        @winner = 'Egalité'
        @winner_code = :equality

      end
    end

    private

    # Compute points given by each loss or destroyed units.
    #
    # @param opponent [Gang] the attacker.
    #
    # @return [Array] Strings to be printed in the fight log
    # @return [Integer] The total of the points earned
    def compute_result_for( opponent )
      total = 0
      points_list = []

      opponent.tmp_units.each do |unit|
        points = unit.losses_points

        # points_list << "L'unité #{unit.full_name} a eu #{bc.deads} pertes ce qui donne #{points} points."
        total += points
      end

      return points_list, total
    end

    # Compute the losses points do determine victory
    def losses_points
      pts = ( ( unit.amount - unit.remains ) * unit.massacre_points ).ceil.to_i

      if unit.remains == 0
        pts += unit.legendary ? 4 : 1
      end

      pts
    end

    def sub_recover_units( gang )
      gang.units.each do |unit|
        recover_to( unit )
      end
    end

    # This method compute the recover_to level. The rules implies that an unit recover up to half a point miniatures.
    #
    # @return [Integer] the new number of miniatures of the units.
    def recover_to( unit )
      if unit.remains > 0
        max_amount_unit = unit.unit_data_open_hash.amount
        half_max_amount = max_amount_unit / 2.0

        unit.amount = [ ( ( unit.remains / half_max_amount ).ceil * half_max_amount ).to_i, unit.amount ].min
        unit.save!
      end
    end

  end

end