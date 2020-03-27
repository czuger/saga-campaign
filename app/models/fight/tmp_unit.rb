module Fight

  # This class is used to work on another class then the Unit class during the fight.
  class TmpUnit

    def initialize( unit )
      @libe = unit.libe
      @weapon = unit.weapon

      @initial_amount = unit.amount
      @current_amount = @initial_amount
      @resistance = unit.resistance if unit.respond_to?( :resistance )
      @fatigue = 0
      @already_activate_this_turn = false

      @min_units_for_saga_dice = unit.min_units_for_saga_dice
      @initiative = unit.initiative
    end

    def action_dice?
      @current_amount >= @min_units_for_saga_dice
    end

    def activation_weight
      base = @already_activate_this_turn ? 1 : 1000
      base * @initiative
    end

  end

end
