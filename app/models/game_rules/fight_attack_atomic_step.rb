module GameRules

  # Represent a very single attack step. Can be the attack or the retailation
  #
  # @param attacker [Unit] the attacker.
  # @param defender [Unit] the defender.
  # @param attack_type [Symbol] Can be :attack or :retail depending if you are performing the true attack or the retail.
  #
  # @return nil
  class FightAttackAtomicStep

    attr_reader :attack_type, :final_hits

    def initialize( attacker, defender, attack_phase )
      @attacker = attacker
      @defender = defender
      @attack_phase = attack_phase
    end

    # Roll the dice for the attack
    #
    # @param attacker [Unit] the attacker.
    # @param defender [Unit] the defender.
    #
    # @return nil
    def roll_attack( attacker, defender )
      set_attack_info(attacker, defender )

      @roll_result = Hazard.from_string "s#{@dice_pool}d6"
      @hits = @roll_result.rolls.select{ |d| d >= @opponent_armor }

      @opponent_saves_result = Hazard.from_string "s#{@hits.count}d6"
      @opponent_saves = @opponent_saves_result.rolls.select{ |d| d >= @opponent_save }

      @final_hits = [@hits.count - @opponent_saves.count, 0].max
    end

    # Get subdata for fight detail logging
    #
    # @return [Hash] Log details
    def get_log_data
      {
        attack_result:
          { hits: @hits.count, hits_rolls: @roll_result.rolls, saves: @opponent_saves.count,
            saves_rolls: @opponent_saves_result.rolls, damages: @final_hits },

        attack_type: { type: @attack_type, dice_pool: @dice_pool, opponent_armor: @opponent_armor,
                       opponent_save: @opponent_save },
      }
    end

    private

    # Get the type of the attack
    #
    # @param attacker [Unit] the attacker.
    #
    # @return [Symbol] the type of the attack that will be performed.
    def get_attack_type( attacker )
      attack_type = :cac

      if @attack_phase == :attack
        attack_type = :magic if attacker.has_magick?
        attack_type = :distance if attacker.distance_attacking_unit?
      end

      attack_type
    end

    # Compute the the attacking and defending values required for the fight.
    #
    # @param attacker [Unit] the attacker.
    # @param defender [Unit] the defender.
    #
    # @return [Array] [Attacker dice pool size, Target armor value, Target save value]
    def set_attack_info(attacker, defender )

      @attack_type = get_attack_type( attacker )

      case @attack_type
        when :magic
          @dice_pool = 6
          @opponent_armor = 3
          @opponent_save = 6
        when :distance
          @dice_pool = (attacker.amount * attacker.damage_ranged).to_i
          @opponent_armor = defender.armor_ranged
          @opponent_save = 5
        when :cac
          @last_attack_cac = true

          @dice_pool = (attacker.amount * attacker.damage_cac).to_i
          @opponent_armor = defender.armor_cac
          @opponent_save = 4
        else
          raise "Attack type unknown : #{@attack_type}"
      end
    end

  end

end
