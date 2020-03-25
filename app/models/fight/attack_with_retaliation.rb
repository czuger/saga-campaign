require 'ostruct'

module Fight

  # Represent a full attack step. Including a retaliation in case of cac attack and hits assignment.
  class AttackWithRetaliation

    def initialize( body_count )
      @hits_log = []

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
      @attacker = attacker
      @defender = defender

      # First the regular attack
      @attack = AttackAtomicStep.new(attacker, defender, :attack )
      attack_hits = @attack.roll_attack

      if @attack.attack_type == :cac
        # If attack was cac then we perform the retail
        @retaliation = AttackAtomicStep.new(defender, attacker, :retaliation )
        retail_hits = @retaliation.roll_attack

        # We assign the retailing hits must be assigned after.
        attacker_units = assign_hits( attacker_units, attacker, retail_hits )
      end

      # And the defending hits
      defender_units = assign_hits( defender_units, defender, attack_hits )
      [attacker_units, defender_units, attacker, defender ]
    end

    # Get subdata for fight detail logging
    #
    # @return [OpenStruct] Log details
    def get_log_data
      OpenStruct.new(
        {
          can_attack: true,
          attack: @attack.get_log_data(),
          retaliation: @retaliation&.get_log_data(),
          hits_assignment: @hits_log,
          attacker: @attacker.log_data,
          defender: @defender.log_data
        }
      )
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
      if hits > 0
        if defender.get_protection > 0
          @hits_log << sub_assign_hits( defender, defender.get_protection, hits, :protection ) do |real_hits, log|
            defender.decrease_protection!( real_hits )
            log
          end
        else
          @hits_log << sub_assign_hits( defender, defender.amount, hits, :casualties ) do |real_hits, log|
            defender.amount -= real_hits

            if defender.amount <= 0
              log.unit_destroyed = true
              defender_units.delete( defender )
            end

            log
          end
        end
      end

      defender_units
    end

    def sub_assign_hits( defender, amount, hits, type )
      real_hits = [ amount, hits ].min

      log = OpenStruct.new(
        type: type,
        before: amount,
        after: amount - real_hits, damages: real_hits, hits: hits, unit: defender.log_data )

      log = yield( real_hits, log )
      log
    end
  end
end
