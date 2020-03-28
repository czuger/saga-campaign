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

    def initialize( attacker, defender, attack_type, attack_phase = :attack )
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

      if @dice_pool > 0
        @roll_result = Hazard.from_string "s#{@dice_pool}d6"
        @hits = @roll_result.rolls.select{ |d| d >= @opponent_armor }
      else
        raise "@dice_pool == 0 for #{@attacker.to_s}"
      end

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
        log_level: self.class.to_s,
        hits: @hits.count, hits_rolls: @roll_result.rolls, saves: (@opponent_saves&.count || 0),
        saves_rolls: (@opponent_saves_result&.rolls || []), damages: @final_hits, attack_type: @attack_type,
        dice_pool: @dice_pool, opponent_armor: @opponent_armor, opponent_save: @opponent_save,
        attacker: @attacker_before_attack.log_data, defender: @defender_before_attack.log_data, attack_phase: @attack_phase
      )
    end

    def to_s
      attack_detail_string_dice_pool_part = I18n.t( 'fights.opponent_turn_detail.attack_detail_string_dice_pool_part', count: @dice_pool )
      attack_detail_string_hits_part = I18n.t( 'fights.opponent_turn_detail.attack_detail_string_hits_part', count: @hits )

      attack_phase = I18n.t( 'fights.opponent_turn_detail.attack_phase.' + @attack_phase.to_s.freeze )

      attacker_name = Unit.short_name_from_log_data( @attacker.log_data )
      defender_name = Unit.short_name_from_log_data( @defender.log_data )

      attack = I18n.t( 'fights.opponent_turn_detail.attack_detail_string', attacker_name: attacker_name, defender_name: defender_name,
                  attack_type_name: attack_type_name(@attack_type),
                  dice_pool_part: attack_detail_string_dice_pool_part,
                  opponent_armor: @opponent_armor,
                  hits_part: attack_detail_string_hits_part,
                  attacker_count: @attacker.current_amount, defender_count: @defender.current_amount,
                  hits_rolls: @hits_rolls, attack_phase: attack_phase )

      defend_detail_string_hits_part = I18n.t( 'fights.opponent_turn_detail.attack_detail_string_hits_part', count: @damages )
      defend_detail_string_saves_part = I18n.t( 'fights.opponent_turn_detail.defend_detail_string_saves_part', count: @opponent_saves )

      defense = I18n.t( 'fights.opponent_turn_detail.defend_detail_string', defender_name: defender_name, opponent_save: @opponent_save,
                   saves_rolls: @saves_rolls, saves_string: defend_detail_string_saves_part,
                   hits_part: defend_detail_string_hits_part )

      attack.upcase_first + ' ' + defense.upcase_first
    end

    private

    def attack_type_name( attack_type )
      return 'par sortilège' if attack_type == :magic
      return 'à distance' if attack_type == :distance
      'au corps à corps'
    end

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
