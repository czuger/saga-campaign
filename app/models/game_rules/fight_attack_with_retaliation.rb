require 'ostruct'

module GameRules

  # Represent a full attack step. Including a retaliation in case of cac attack and hits assignment.
  class FightAttackWithRetaliation

    def initialize( body_count )
      @hits_log = {}

      @body_count = body_count
    end

    # Represent a full attack including retaliation. This method is mutative for all parameters.
    #
    # @param attacker_units [Array] the units of the attacker.
    # @param defender_units [Array] the units of the defender.
    # @param attacker [Unit] the attacker.
    # @param defender [Unit] the defender.
    #
    # @return [all input parameters].
    def perform_attack( attacker_units, defender_units, attacker, defender )

      # First the regular attack
      @attack = FightAttackAtomicStep.new( attacker, defender, :attack )
      attack_hits = @attack.roll_attack( attacker, defender )

      if @attack.attack_type == :cac
        # If attack was cac then we perform the retail
        @retaliation = FightAttackAtomicStep.new(attacker, defender, :retaliation )
        retail_hits = @retaliation.roll_attack(defender, attacker )

        # We assign the retailing hits must be assigned after.
        attacker_units = assign_hits( attacker_units, attacker, retail_hits )
      end

      # And the defending hits
      defender_units = assign_hits( defender_units, defender, attack_hits )
      [attacker_units, defender_units, attacker, defender ]
    end

    # Get subdata for fight detail logging
    #
    # @return [Hash] Log details
    def get_log_data
      { attack: @attack.get_log_data(), retaliation: @retaliation&.get_log_data(), hits_assignment: @hits_log }
    end

    private

    # Assigns the hits and destroy the unit if it has no more minis
    #
    # @param defender_units [Array] the units of the defender.
    # @param defender [Unit] the defender.
    # @param hits [Integer] the amount of hits to take.
    #
    # @return [Array] the units of the defender.
    def assign_hits( defender_units, defender, hits )
      if defender.get_protection > 0
        @hits_log[ defender.full_name ] = { type: :protection, prot_before: defender.get_protection }
        defender.decrease_protection!( hits )
        @hits_log[ defender.full_name ][ :prot_after ] = defender.get_protection
      else
        @hits_log[ defender.full_name ] = { type: :loss, amount_before: defender.amount }

        units_to_loose = [ hits, defender.amount ].min

        defender.amount -= units_to_loose
        @hits_log[ defender.full_name ][ :amount_after ] = defender.amount

        @body_count[ defender.id ] ||= OpenStruct.new( unit: defender, deads: 0 )
        @body_count[ defender.id ].deads += units_to_loose
      end

      @hits_log[ defender.full_name ][ :hits ] = hits

      if defender.amount <= 0
        @hits_log[ defender.full_name ][ :unit_destroyed ] = true
        defender_units.delete( defender )
        @body_count[ defender.id ].destroyed = true
      end

      defender_units
    end


  end

end
