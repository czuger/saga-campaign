module Fight

  # This class is used to work on another class then the Unit class during the fight.
  class TmpUnit

    attr_reader :activation_dice
    attr_accessor :already_activate_this_turn

    def initialize( unit )
      # p unit
      unit_data = unit.unit_data_open_hash
      # p unit_data

      @libe = unit.libe
      @weapon = unit.weapon

      @initial_amount = unit.amount
      @current_amount = @initial_amount
      @resistance = unit.resistance if unit.respond_to?( :resistance )
      @fatigue = 0
      @already_activate_this_turn = false

      @min_units_for_saga_dice = unit_data.min_units_for_saga_dice
      @initiative = unit_data.initiative
      @activation_dice = unit_data.activation_dice
    end

    def action_dice?
      @current_amount >= @min_units_for_saga_dice
    end

    def activation_weight
      base = @already_activate_this_turn ? 1 : 1000
      base * @initiative
    end

    def activation_weight
      base = @already_activate_this_turn ? 1 : 1000
      base * @initiative
    end


  end

end
