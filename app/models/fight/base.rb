module Fight

  class Base

    attr_reader :combat_log, :body_count, :result

    def initialize( campaign_id, location, attacking_gang_id, defending_gang_id, save_result: true, verbose: false )
      @attacking_gang = TmpGang.new( attacking_gang_id, :attacker, verbose: verbose )
      @defending_gang = TmpGang.new( defending_gang_id, :defender, verbose: verbose )

      @combat_log = []

      @campaign_id = campaign_id
      @location = location

      @body_count = {}

      @save_result = save_result
      @verbose = verbose
    end

    def go
      1.upto(6).each do |i|
        round_log_shell = OpenStruct.new(
          round: i,
          turn_phases: OpenStruct.new( attacker: nil, defender: nil ),
          attacker_name: @attacker_name, defender_name: @defender_name )

        attack_count = ( i == 1 ? 3 : 8 )

        round_log_shell.attacker = tour(@attacking_gang, @defending_gang, attack_count )
        puts
        puts
        round_log_shell.defender = tour(@defending_gang, @attacking_gang, attack_count )

        @combat_log << round_log_shell

        # break if @player_1_units.empty? || @player_2_units.empty?
      end

      # @result = AttackCountPoints.new(@player_1, @player_2, @body_count ).do
      # save_result( @result ) if @save_result

      self
    end

    # Play a full tour where player1 and player 2 fights
    #
    # @param attacking_gang [TmpGang] the attacker gang.
    # @param defending_gang [Array] the defender gang.
    #
    # @return nil
    def tour(attacking_gang, defending_gang, max_attack_count )
      units_actions_log = []

      dice = ActionDicePool.new( attacking_gang )
      p dice.to_s

      while dice.remaining_action_dice?
        # p dice.to_s

        next_attacking_unit, used_die = attacking_gang.get_next_unit_to_activate( dice )
        # p "priority = #{next_attacking_unit[0]}, #{next_attacking_unit[1].to_s}"

        if next_attacking_unit
          next_attacking_unit = next_attacking_unit[1]

          dice.consume_die!( used_die )

          ad = ActionDecision.new(
            attacking_gang, defending_gang,next_attacking_unit, verbose: @verbose )
          units_actions_log << ad.do_something

          next_attacking_unit.already_activate_this_turn = true

          puts
        end
      end

      units_actions_log
    end

    # Save results in the database.
    #
    # @return nil
    def save_result( result )

      fight_data = {
        attacker: @player_1.player.user.name,
        defender: @player_2.player.user.name,
        attacking_gang_no: @player_1.id,
        defending_gang_no: @player_2.id,
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
      @attack_trigger = unit.can_attack_trigger
      @dice = Hazard.d100

      @dice <= @attack_trigger
    end

    def get_target( defender_units )
      wt = WeightedTable.new( floating_points: true )

      units = defender_units.map{ |u| [ u.being_targeted_probability, u ] }
      wt.from_weighted_table( units)

      wt.sample
    end
  end

end