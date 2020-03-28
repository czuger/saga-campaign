module Fight

  class HitsAssignment

    def initialize( defending_gang, defending_unit, verbose: false )
      @defending_gang = defending_gang
      @defending_unit = defending_unit

      @verbose = verbose
    end

    # Assigns the hits and destroy the unit if it has no more minis
    #
    # @param hits [Integer] the amount of hits to take.
    #
    # @return [Array] the units of the defender.
    def assign_hits!( hits )
      @defending_unit.assign_hits!( hits )

      if @verbose
        defend_detail_string_hits_part = I18n.t( 'fights.opponent_turn_detail.attack_detail_string_hits_part'.freeze, count: hits )
        puts I18n.t( 'fights.opponent_turn_detail.final_hits_string', hits_part: defend_detail_string_hits_part )
      end

      # if @defending_unit.amount <= 0
      #   # log.unit_destroyed = true
      #   # @defending_gang.destroy( @defending_unit )
      # end
    end


  end

end
