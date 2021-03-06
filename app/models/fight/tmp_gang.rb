module Fight
  class TmpGang

    attr_reader :tmp_units, :player_name, :gang_name

    def initialize( gang_id, attacker_or_defender, verbose: false )
      @gang = Gang.find( gang_id )
      @player_name = @gang.player.user.name
      @gang_name = @gang.name

      @attacker_or_defender = attacker_or_defender

      @tmp_units = @gang.units.map{ |u| TmpUnit.new( u, attacker_or_defender, verbose: verbose ) }

      @verbose = verbose
    end

    def get_next_unit_to_activate( action_dice_pool )
      # The last element of the last tuple. The unit with the highest initiative.
      @tmp_units.reject{ |u| u.destroyed? }.map{ |u| [u.activation_weight, u ] }.sort{ |a, b| b[0] <=> a[0] }.each do |unit|
        die = action_dice_pool.can_activate_unit?( unit[1] )
        return unit, die if die
      end

      return false, false
    end

    def units_in_range( unit )
      units = @tmp_units.select{ |u| u.distance( unit ) <= unit.attack_range }

      puts "Unités à portée = #{units.map{ |u| "<#{u.name} - #{u.current_position}>" }.join( ', ' )}" if @verbose

      units
    end

    # Remove an unit from the @gang
    #
    # @param unit [TmpUnit] the unit to remove
    def remove_unit!( unit )
      puts "#{unit.unit_name} est détruite." if @verbose

      # Unit is not really removed now, we check if it is destroyed.
      # @tmp_units.delete( unit )
    end

    # Compute the position of the nearest enemy. This will be the melee spot
    #
    # @param unit [TmpUnit] the unit from which we will check the distance.
    #
    # @return Integer the position of the nearest unit.
    def nearest_enemy_unit( unit )
      distance_min = Float::INFINITY
      nearest_unit = nil

      @tmp_units.each do |u|
        d = u.distance( unit )
        if d < distance_min
          d = distance_min
          nearest_unit = u
        end
      end

      nearest_unit
    end

    def casualties
      @tmp_units.map{ |u| u.casualties }
    end

    def has_units?
      @tmp_units.reject{ |u| u.destroyed? }.count != 0
    end

    def lord_surviving_count
      @tmp_units.select{ |u| u.libe == 'seigneur' }.first&.destroyed? ? 0 : 1
    end

    def losses_stats
      OpenStruct.new(initial_number_of_miniatures: @tmp_units.map{ |u| u.initial_amount }.inject( &:+ ) || 0,
                     remaining_number_of_miniatures: @tmp_units.map{ |u| u.current_amount }.inject( &:+ ) || 0 )
    end

    def apply_casualties!
      @tmp_units.each do |unit|
        unit.apply_casualties!
      end

      if @gang.units.count == 0
        @gang.gang_destroyed = true
      end

      @gang.points = @gang.units.sum( :points )
      @gang.save!
    end

  end
end

