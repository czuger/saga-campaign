module Fight

  # This class is used to work on another class then the Unit class during the fight.
  class TmpUnit

    attr_reader :activation_dice, :attack_range, :current_position
    attr_accessor :already_activate_this_turn

    def initialize( unit, attacker_or_defender )
      # p unit
      unit_data = unit.unit_data_open_hash
      # p unit_data

      @libe = unit.libe
      @weapon = unit.weapon
      @name = unit.name
      @attacker_or_defender = attacker_or_defender

      @initial_amount = unit.amount
      @current_amount = @initial_amount
      @resistance = unit.resistance if unit.respond_to?( :resistance )
      @fatigue = 0

      @initial_position = unit_data.initial_position
      @initial_position = 36 - @initial_position if attacker_or_defender == :defender
      @current_position = @initial_position
      @movement = unit_data.movement
      @algo_advance = unit_data.algo_advance

      @attack_range = unit_data.attack_range

      @min_units_for_saga_dice = unit_data.min_units_for_saga_dice
      @initiative = unit_data.initiative
      @activation_dice = unit_data.activation_dice

      @already_activate_this_turn = false
    end

    def action_dice?
      @current_amount >= @min_units_for_saga_dice
    end

    def activation_weight
      base = @already_activate_this_turn ? 1 : 1000
      base * @initiative
    end

    # Advance from the required advance movement. Don't cross enemy positions.
    #
    # @param nearest_enemy_position [Integer] the position we do not have to cross.
    def advance( nearest_enemy_position )
      if @attacker_or_defender == :attacker
        @current_position = [@current_position + @movement, nearest_enemy_position].min
      else
        @current_position = [@current_position - @movement, nearest_enemy_position].max
      end

      puts name + " avance en position #{@current_position}"
    end

    # Used to store unit data for logging (to remember info when the unit will be destroyed)
    def log_data
      OpenStruct.new( libe: @libe, weapon: @weapon, name: @name, amount: @current_amount )
    end

    def name
      Unit.long_name_from_log_data( log_data )
    end

    def distance( unit )
      [ @current_position - unit.current_position, unit.current_position - @current_position ].max
    end

  end

end
