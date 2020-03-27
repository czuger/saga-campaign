module Fight
  class TmpGang

    attr_reader :units

    def initialize( gang_id, attacker_or_defender )
      gang = Gang.find( gang_id )
      @attacker_name = gang.player.user.name

      @attacker_or_defender = attacker_or_defender

      @units = gang.units.map{ |u| TmpUnit.new( u, attacker_or_defender ) }
    end

    def get_next_unit_to_activate( action_dice_pool )
      # The last element of the last tuple. The unit with the highest initiative.
      @units.map{ |u| [ u.activation_weight, u ] }.sort{ |a, b| b[0] <=> a[0] }.each do |unit|
        die = action_dice_pool.can_activate_unit?( unit[1] )
        return unit, die if die
      end

      return false, false
    end

  end
end

