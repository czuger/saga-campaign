module GameRules

  class Fight

    attr_reader :combat_log, :body_count, :result

    def initialize( campaign_id, location, attacking_gang_id, defender_gang_id, save_result: true )
      @combat_log = []

      @campaign_id = campaign_id
      @location = location

      @attacking_gang_id = attacking_gang_id
      @defender_gang_id = defender_gang_id

      @body_count = {}

      @save_result = save_result
    end

    def go
      load

      1.upto(6).each do |i|
        @round_log_shell = { round: i, turns_log: [] }

        attack_count = ( i == 1 ? 3 : 8 )

        @round_log = []
        tour(@player_1_units, @player_2_units, attack_count )
        @round_log_shell[:turns_log] << { turn_of: @player_1.player.user.name, turn_log: @round_log }

        @round_log = []
        tour(@player_2_units, @player_1_units, Float::INFINITY )
        @round_log_shell[:turns_log] << { turn_of: @player_2.player.user.name, turn_log: @round_log }

        @combat_log << @round_log_shell

        break if @player_1_units.empty? || @player_2_units.empty?
      end

      @result = FightAttackCountPoints.new( @player_1, @player_2, @body_count ).do
      save_result( @result ) if @save_result

      self
    end

    # Play a full tour where player1 and player 2 fights
    #
    # @param attacker_units [Array] all attacker units.
    # @param defender_units [Array] all defender units.
    #
    # @return nil
    def tour(attacker_units, defender_units, max_attack_count )
      # p attacker_units.map{ |e| e.id }

      attacks_performed = 0

      attacker_units.each do |attacker|

        break if attacks_performed >= max_attack_count || attacker_units.empty? || defender_units.empty?

        @single_attack_log = {}
        @step_attack_log = {}

        if will_attack?(attacker )
          f = FightAttackWithRetaliation.new( @body_count )
          attacks_performed += 1

          defender = get_target( defender_units )

          attacker_units, defender_units, attacker, defender =
            f.perform_attack( attacker_units, defender_units, attacker, defender )

          @single_attack_log[ :combat_result ] = f.get_log_data
        end

        @round_log << @single_attack_log

      end
    end

    def load
      @player_1 = Gang.find( @attacking_gang_id )
      @player_2 = Gang.find( @defender_gang_id )

      @player_1_units = @player_1.units.to_a
      @player_2_units = @player_2.units.to_a
    end

    # Save results in the database.
    #
    # @return nil
    def save_result( result )

      fight_data = {
        attacker: @player_1.player.user.name,
        defender: @player_2.player.user.name,
        attacker_gang_no: @player_1.id,
        defender_gang_no: @player_2.id,
        result: result
        }

      FightResult.create!( campaign_id: @campaign_id, location: @location, fight_data: fight_data, fight_log: @combat_log )

      result
    end

    # Test if a combat should continue.
    #
    # @return [Boolean] true or false
    def combat_continue?( attacker_units, defender_units )
      attacker_units.empty? || defender_units.empty?
    end

    def will_attack?( unit )
      ca = unit.can_attack_trigger

      dice = Hazard.d100

      @single_attack_log[ :can_attack ] = {
        can_attack: dice <= ca, min_to_attack: ca, roll: dice, attacker: unit.full_name }

      dice <= ca
    end

    def get_target( defender_units )
      wt = WeightedTable.new( floating_points: true )

      units = defender_units.map{ |u| [ u.being_targeted_probability, u ] }
      wt.from_weighted_table( units)

      wt.sample
    end
  end

end