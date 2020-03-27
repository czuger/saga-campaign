module Fight
  class TmpGang

    attr_reader :units

    def initialize( gang_id )
      gang = Gang.find( gang_id )
      @attacker_name = gang.player.user.name

      @units = gang.units.map{ |u| TmpUnit.new( u ) }
    end

    def get_next_unit_to_activate( action_dice_pool )
      # The last element of the last tuple. The unit with the highest initiative.
      @units.map{ |u| [ u.activation_weight, u ] }.sort.last.last
    end

  end
end

