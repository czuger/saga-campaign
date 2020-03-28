module Fight

  # This class is used to work on another class then the Unit class during the fight.
  class TmpUnit

    attr_reader :activation_dice, :attack_range, :current_position, :armor_cac, :armor_ranged, :resistance, :current_amount
    attr_accessor :already_activate_this_turn, :fatigue

    def initialize( unit, attacker_or_defender, verbose: false )
      unit_data = unit.unit_data_open_hash

      @libe = unit.libe
      @weapon = unit.weapon
      @name = unit.name
      @attacker_or_defender = attacker_or_defender

      @initial_amount = unit.amount
      @current_amount = @initial_amount
      @resistance = unit.resistance if unit.respond_to?( :resistance )
      @fatigue = 0
      @max_fatigue = unit_data.options.include?( 'imposant'.freeze ) ? 4 : 3

      @damage_cac = unit_data.damage.cac
      @damage_ranged = unit_data.damage.ranged
      @armor_cac = unit_data.armor.cac
      @armor_ranged = unit_data.armor.ranged

      @initial_position = unit_data.initial_position
      @initial_position = 36 - @initial_position if attacker_or_defender == :defender
      @current_position = @initial_position
      @movement = unit_data.movement
      @algo_advance = unit_data.algo_advance

      @attack_range = unit_data.attack_range

      @min_units_for_saga_dice = unit_data.min_units_for_saga_dice
      @initiative = unit_data.initiative
      @activation_dice = unit_data.activation_dice

      @options = unit_data.options

      @already_activate_this_turn = false

      @verbose = verbose
    end

    def action_dice?
      @current_amount >= @min_units_for_saga_dice
    end

    def activation_weight
      base = (@already_activate_this_turn ? 0.25 : 1) * (1.0 / (1+@fatigue)) * (exhausted? ? -Float::INFINITY : 1)
      # p "#{to_s} : base=#{base} * @initiative=#{@initiative} = #{base * @initiative}" if @verbose
      base * @initiative
    end

    def rest!
      @fatigue -= 1
    end

    def exhausted?
      @fatigue >= @max_fatigue
    end

    def wounded?
      @current_amount < @initial_amount / 2 || @resistance && @fatigue >= @max_fatigue / 2
    end

    def end_action
      if @already_activate_this_turn
        @fatigue += 1
      else
        @already_activate_this_turn = true
      end
    end

    def ranged_dice_pool
      [(@current_amount * @damage_ranged).ceil.to_i, 8].min
    end

    def melee_dice_pool
      [(@current_amount * @damage_cac).ceil.to_i, 16].min
    end

    # Advance from the required advance movement. Don't cross enemy positions.
    #
    # @param nearest_enemy_position [Integer] the position we do not have to cross.
    def advance( nearest_enemy_position )
      tmp_movement = @movement

      # Units that try to keep distances only advance half distance
      tmp_movement /= 2 if keeping_distance_unit?

      if @attacker_or_defender == :attacker
        @current_position = [@current_position + tmp_movement, nearest_enemy_position].min
      else
        @current_position = [@current_position - tmp_movement, nearest_enemy_position].max
      end

      puts name + " avance en position #{@current_position}" if @verbose
    end

    # Fall back
    def fall_back
      if @attacker_or_defender == :attacker
        @current_position -= @movement
      else
        @current_position += @movement
      end

      puts name + " recule en position #{@current_position}" if @verbose
    end

    # Used to store unit data for logging (to remember info when the unit will be destroyed)
    def log_data
      OpenStruct.new( libe: @libe, weapon: @weapon, name: @name, amount: @current_amount )
    end

    def name
      Unit.short_name_from_log_data( log_data )
    end

    def unit_name
      "L'unité " + Unit.short_name_from_log_data( log_data )
    end

    def distance( unit )
      [ @current_position - unit.current_position, unit.current_position - @current_position ].max
    end

    def to_s
      [ "name=#{@name}", "fatigue=#{@fatigue}", "current_position=#{@current_position}", "attack_range=#{@attack_range}" ].join( ', ' )
    end

    # Assigns the hits
    #
    # @param hits [Integer] the amount of hits to take.
    def assign_hits!( hits )
      if hits > 0
        if resistance
          assign_hits_with_resistance!( hits )
        else
          assign_hits_without_resistance!( hits )
        end
      end
    end

    private

    def assign_hits_with_resistance!( hits )
      remaining_fatigue = @max_fatigue - @fatigue

      max_cancelable_hits = @resistance * remaining_fatigue

      if hits >= max_cancelable_hits
        @fatigue += (hits.to_f / @resistance).ceil.to_i
      else
        @fatigue = @max_fatigue
        assign_hits_without_resistance( hits )
      end
    end

    def assign_hits_without_resistance!( hits )
      real_hits = [ hits, @current_amount ].min
      @current_amount -= real_hits
    end

    def keeping_distance_unit?
      @attack_range > 0 || @libe == 'seigneur'.freeze
    end

  end

end
