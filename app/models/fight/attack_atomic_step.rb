module Fight

  # Represent a very single attack step. Can be the attack or the retailation
  #
  # @param attacker [Unit] the attacker.
  # @param defender [Unit] the defender.
  # @param attack_type [Symbol] The type of the attack : :ranged, :cac, :magic, etc ...
  # @param attack_phase [Symbol] Can be :attack or :retail depending if you are performing the true attack or the retail.
  #
  # @return nil
  class AttackAtomicStep

    attr_reader :attack_type, :final_hits

    def initialize( attacker, defender, attack_type, attack_phase= nil )
      @attacker_before_attack = attacker.dup
      @defender_before_attack = defender.dup

      @attacker = attacker
      @defender = defender

      @attack_phase = attack_phase
      @attack_type = attack_type
    end

    # Roll the dice for the attack
    #
    # @return nil
    def roll_attack
      set_attack_info

      @dice_pool = [@dice_pool, 16].min

      @roll_result = Hazard.from_string "s#{@dice_pool}d6"
      @hits = @roll_result.rolls.select{ |d| d >= @opponent_armor }

      if @hits.count > 0
        @opponent_saves_result = Hazard.from_string "s#{@hits.count}d6"
        @opponent_saves = @opponent_saves_result.rolls.select{ |d| d >= @opponent_save }
      end

      @final_hits = [@hits.count - (@opponent_saves&.count || 0), 0].max
    end

    # Get subdata for fight detail logging
    #
    # @return [Hash] Log details
    def get_log_data
      OpenStruct.new(
        hits: @hits.count, hits_rolls: @roll_result.rolls, saves: (@opponent_saves&.count || 0),
        saves_rolls: (@opponent_saves_result&.rolls || []), damages: @final_hits, attack_type: @attack_type,
        dice_pool: @dice_pool, opponent_armor: @opponent_armor, opponent_save: @opponent_save,
        attacker: @attacker_before_attack.log_data, defender: @defender_before_attack.log_data, attack_phase: @attack_phase
      )
    end

    private

    # Compute the the attacking and defending values required for the fight.
    #
    # @return [Array] [Attacker dice pool size, Target armor value, Target save value]
    def set_attack_info
      case @attack_type
        when :magic
          @dice_pool = 6
          @opponent_armor = 2
          @opponent_save = 6
        when :ranged
          @dice_pool = @attacker.ranged_dice_pool
          @opponent_armor = @defender.armor_ranged
          @opponent_save = 5
        when :cac
          @last_attack_cac = true

          @dice_pool = @attacker.melee_dice_pool
          @opponent_armor = @defender.armor_cac
          @opponent_save = 4
        else
          raise "Attack type unknown : #{@attack_type}"
      end
    end

  end

end
