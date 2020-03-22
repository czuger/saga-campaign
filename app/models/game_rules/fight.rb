module GameRules

  class Fight

    attr_reader :combat_log

    def initialize( campaign_id, location, attacking_gang_id, defender_gang_id )
      @combat_log = []

      @campaign_id = campaign_id
      @location = location

      @attacking_gang_id = attacking_gang_id
      @defender_gang_id = defender_gang_id
    end

    def go
      load

      1.upto(6).each do |i|
        @round_log = []
        @round_log_shell = { round: i, turns_log: [] }

        attack_count = ( i == 1 ? 4 : Float::INFINITY )
        tour(@player_1_units, @player_2_units, attack_count )
        @round_log_shell[:turns_log] << { turn_of: @player_1.player.user.name, turn_log: @round_log }

        tour(@player_2_units, @player_1_units, Float::INFINITY )
        @round_log_shell[:turns_log] << { turn_of: @player_2.player.user.name, turn_log: @round_log }

        @combat_log << @round_log_shell

        break if @player_1_units.empty? || @player_2_units.empty?
      end

      result = check_result
      save_result( result )
    end

    private

    # Play a full tour where player1 and player 2 fights
    #
    # @param attacker_units [Array] all attacker units.
    # @param defender_units [Array] all defender units.
    #
    # @return nil
    def tour(attacker_units, defender_units, max_attack_count )
      attacker_units.each_with_index do |attacker, i|

        break if i >= max_attack_count || attacker_units.empty? || defender_units.empty?

        @single_attack_log = { attacker: attacker.full_name }
        @step_attack_log = {}

        if will_attack?(attacker)
          f = FightAttackWithRetaliation.new

          defender = get_target( defender_units )
          @single_attack_log[ :defender ] = defender.full_name

          attacker_units, defender_units, attacker, defender =
            f.perform_attack( attacker_units, defender_units, attacker, defender )

          @single_attack_log[ :combat_result ] = f.get_log_data
          @round_log << @single_attack_log
        end
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

      p @player_1

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

    def check_result
      result = :equality

      if @player_1_units.empty? || @player_1_units.count < @player_2_units.count
        result = :defender
      elsif @player_2_units.empty? || @player_1_units.count > @player_2_units.count
        result = :attacker
      end

      result
    end


    def will_attack?( unit )
      ca = unit.unit_data.fight_info.can_attack
      dice = Hazard.d100

      @single_attack_log[ :can_attack ]= { min_to_attack: ca, roll: dice }

      if dice <= ca
        true
      else
        false
      end
    end

    def get_target( defender_units )
      wt = WeightedTable.new( floating_points: true )

      units = defender_units.map{ |u| [ u.unit_data.fight_info.being_targeted, u ] }
      wt.from_weighted_table( units)

      wt.sample
    end
  end

end