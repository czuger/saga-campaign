module Fight

  class Base

    attr_reader :combat_log, :body_count, :result

    def initialize( campaign_id, location, attacking_gang_id, defending_gang_id, save_result: true )
      @attacker_gang = TmpGang.new( attacking_gang_id, :attacker )
      @defender_gang = TmpGang.new( defending_gang_id, :defender )

      @combat_log = []

      @campaign_id = campaign_id
      @location = location

      @body_count = {}

      @save_result = save_result
    end

    def go
      1.upto(3).each do |i|
        round_log_shell = OpenStruct.new(
          round: i,
          turn_phases: OpenStruct.new( attacker: nil, defender: nil ),
          attacker_name: @attacker_name, defender_name: @defender_name )

        attack_count = ( i == 1 ? 3 : 8 )

        round_log_shell.attacker = tour(@attacker_gang, @defender_gang, attack_count )
        puts
        puts
        round_log_shell.defender = tour(@defender_gang, @attacker_gang, attack_count )

        @combat_log << round_log_shell

        # break if @player_1_units.empty? || @player_2_units.empty?
      end

      # @result = AttackCountPoints.new(@player_1, @player_2, @body_count ).do
      # save_result( @result ) if @save_result

      self
    end

    # Play a full tour where player1 and player 2 fights
    #
    # @param attacker_gang [TmpGang] the attacker gang.
    # @param defender_gang [Array] the defender gang.
    #
    # @return nil
    def tour(attacker_gang, defender_gang, max_attack_count )
      units_actions_log = []

      dice = ActionDicePool.new( attacker_gang )
      p dice.to_s

      while dice.remaining_action_dice?
        # p dice.to_s

        next_attacking_unit, used_die = attacker_gang.get_next_unit_to_activate( dice )
        p "priority = #{next_attacking_unit[0]}, #{next_attacking_unit[1].to_s}"

        if next_attacking_unit
          next_attacking_unit = next_attacking_unit[1]

          dice.consume_die!( used_die )

          ActionDecision.do_something( next_attacking_unit, defender_gang )

          next_attacking_unit.already_activate_this_turn = true

          puts
        end

        # Ajouter les distances
        # Ajouter les mouvements
        # Avancer jusqu'a ce qu'on soit bloqué
        # Tester les ranges et faire une attaque vide

        # teste des range Unit -> Gang

        # break if attacks_performed >= max_attack_count || attacker_units.empty? || defender_units.empty?
        #
        # if will_attack?(attacker )
        #   f = AttackWithRetaliation.new(@body_count )
        #   attacks_performed += 1
        #
        #   defender = get_target( defender_units )
        #
        #   attacker_units, defender_units, attacker, defender =
        #     f.perform_attack( attacker_units, defender_units, attacker, defender )
        #
        #   log = f.get_log_data
        # else
        #   log = OpenStruct.new(
        #     can_attack: false, attack_trigger: @attack_trigger, roll: @dice, attacker: attacker.log_data
        #   )
        # end

        # units_actions_log << log
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