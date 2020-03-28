module Fight
  class TmpGang

    attr_reader :units

    def initialize( gang_id, attacker_or_defender, verbose: false )
      gang = Gang.find( gang_id )
      @attacker_name = gang.player.user.name

      @attacker_or_defender = attacker_or_defender

      @units = gang.units.map{ |u| TmpUnit.new( u, attacker_or_defender, verbose: verbose ) }

      @verbose = verbose
    end

    def get_next_unit_to_activate( action_dice_pool )
      # The last element of the last tuple. The unit with the highest initiative.
      @units.map{ |u| [ u.activation_weight, u ] }.sort{ |a, b| b[0] <=> a[0] }.each do |unit|
        die = action_dice_pool.can_activate_unit?( unit[1] )
        return unit, die if die
      end

      return false, false
    end

    def units_in_range( unit )
      units = @units.select{ |u| u.distance( unit ) <= unit.attack_range }

      puts "Units in range = #{units.map{ |u| "<#{u.name} - #{u.current_position}>" }.join( ', ' )}" if @verbose

      units
    end

    # Compute the position of the nearest enemy. This will be the melee spot
    #
    # @param unit [TmpUnit] the unit from which we will check the distance.
    #
    # @return Integer the position of the nearest unit.
    def nearest_enemy_position( unit )
      distance_min = Float::INFINITY
      nearest_unit = nil

      @units.each do |u|
        d = u.distance( unit )
        if d < distance_min
          d = distance_min
          nearest_unit = u
        end
      end

      nearest_unit.current_position
    end


  end
end

