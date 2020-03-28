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

    @hits_history = OpenStruct.new( attacking_unit: nil, retailing_unit: nil )
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
        @defending_gang, @defending_unit, verbose: @verbose ).assign_hits!( attack_hits )
    end


    # Represent a full melee ttack including retaliation.
    def perform_melee_attack!
      # First the regular attack
      @attack = AttackAtomicStep.new( @attacking_unit, @defending_unit, :melee, :attack )
      attack_hits = @attack.roll_attack

      puts @attack.to_s if @verbose

      if @attack.attack_type == :cac
        # If attack was cac then we perform the retail
        @retaliation = AttackAtomicStep.new(@defending_unit, @attacking_unit, :melee, :retaliation )
        retail_hits = @retaliation.roll_attack

        puts @retaliation.to_s if @verbose

        # Hits must be assigned after the fight.
        @hits_history.retailing_unit = HitsAssignment.new(
          @attacking_gang, @attacking_unit, verbose: @verbose ).assign_hits!( retail_hits )
      end

      # And the attacking hits
      @hits_history.attacking_unit = HitsAssignment.new(
        @defending_gang, @defending_unit, verbose: @verbose ).assign_hits!( attack_hits )
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
