require 'ostruct'

module Fight

  # Represent a full attack step. Including a retaliation in case of cac attack and hits assignment.
  class AttackWithRetaliation

  # A class to handle the full attack process (with eventual retaliation).
  #
  # @param attacking_gang [TmpGang] the units of the attacker.
  # @param defending_gang [TmpGang] the units of the defender.
  # @param attacking_unit [TmpUnit] the attacker.
  # @param defending_unit [TmpUnit] the defender.
  def initialize( attacking_gang, defending_gang, attacking_unit, defending_unit, body_count, verbose: false )
    @attacking_gang = attacking_gang
    @defending_gang = defending_gang
    @attacking_unit = attacking_unit
    @defending_unit = defending_unit

    @hits_log = []

    @body_count = body_count

    @hits_history = OpenStruct.new( attacking_unit: nil, defending_unit: nil )
    @verbose = verbose
  end

    # Represent a ranged attack
    def perform_ranged_attack!
      # First the regular attack
      @attack = AttackAtomicStep.new(@attacking_unit, @defending_unit, :ranged )
      attack_hits = @attack.roll_attack

      puts @attack.to_s if @verbose

      # And the defending hits
      @hits_history.attaking_unit = HitsAssignment.new(
        @defending_gang, @defending_unit, verbose: @verbose )
      @hits_history.attaking_unit.assign_hits!( attack_hits )
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
          log_level: self.class.to_s,
          can_attack: true,
          attack: @attack.get_log_data(),
          retaliation: @retaliation&.get_log_data(),
          hits_assignment: @hits_log,
          attacker: @attacking_unit.log_data,
          defender: @defending_unit.log_data
        }
      )
    end

    private

  end
end
