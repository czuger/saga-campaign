module GameRules

  class Fight

    attr_reader :combat_log

    def initialize( silent = false )
      @silent = silent

      @combat_log = []
    end

    def go
      load

      1.upto(6).each do |i|
        @tour_log = []

        @tour_log << "Tour #{i}"

        attack_count = ( i == 1 ? 4 : Float::INFINITY )
        tour(@player_1_units, @player_2_units, attack_count )
        tour(@player_2_units, @player_1_units, Float::INFINITY )

        @combat_log << @tour_log

        break if @player_1_units.empty? || @player_2_units.empty?
      end

      check_result
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

        @sub_tour_log = []

        break if i >= max_attack_count || attacker_units.empty? || defender_units.empty?

        if will_attack?(attacker)
          attacker_units, defender_units = perform_attack( attacker_units, defender_units, attacker )
        else
          @sub_tour_log << "#{attacker.full_name} n'attaquera pas ce tour."
        end

        @tour_log << @sub_tour_log
      end
    end

    def load
      @player_1 = Gang.find( 1 )
      @player_2 = Gang.find( 2 )

      @player_1_units = @player_1.units.to_a
      @player_2_units = @player_2.units.to_a
    end

    def perform_attack( attacker_units, defender_units, attacker )
      defender = get_target( defender_units )

      @sub_tour_log << "#{attacker.full_name}(#{attacker.amount}) attaque #{defender.full_name}(#{defender.amount})"
      attacking_hits = roll_attack( attacker, defender )

      if @last_attack_cac
        @sub_tour_log << "#{defender.full_name} riposte."
        defending_hits = roll_attack( defender, attacker )
      end

      defender_units = assign_hits( defender_units, defender, attacking_hits )
      attacker_units = assign_hits( attacker_units, attacker, defending_hits ) if defending_hits

      [ attacker_units, defender_units ]
    end


    # Set the type of the attack
    #
    # @param attacker [Unit] the attacker.
    #
    # @return [Symbol] the type of the attack that will be performed.
    def get_attack_type( attacker )
      return :magic if attacker.raw_unit_data[:options]&.include?( 'magie' )

      # Probably a OpenHash conversion issue. == true is required
      return :distance if attacker.raw_unit_data[:fight_info][:distance]

      :cac
    end

    # Compute the the attacking and defending values required for the fight.
    #
    # @param attacker [Unit] the attacker.
    # @param defender [Unit] the defender.
    #
    # @return [Array] [Attacker dice pool size, Target armor value, Target save value]
    def get_attack_info( attacker, defender )

      ai = get_attack_type( attacker )
      @last_attack_cac = false

      case ai
        when :magic
          @sub_tour_log << 'Attaque magique'
          
          [ 6, 4, 6 ]
        when :distance
          dice_pool = (attacker.amount * attacker.unit_data.damage.ranged).to_i
          @sub_tour_log << "Attaque à distance avec #{dice_pool} dés"
          
          [ dice_pool, defender.unit_data.armor.ranged, 5 ]
        when :cac
          @last_attack_cac = true

          dice_pool = (attacker.amount * attacker.unit_data.damage.cac).to_i
          @sub_tour_log << "Attaque au cac avec #{dice_pool} dés"
          
          [ dice_pool, defender.unit_data.armor.cac, 4 ]
        else
          raise "Attack type unknown : #{ai}"
      end
    end

    # Roll the dice for the attack
    #
    # @param attacker [Unit] the attacker.
    # @param defender [Unit] the defender.
    #
    # @return nil
    def roll_attack( attacker, defender )
      dice_pool, opponent_armor, save_value = get_attack_info( attacker, defender )

      roll_string = "s#{dice_pool}d6"
      roll_result = Hazard.from_string roll_string
      hits = roll_result.rolls.select{ |d| d >= opponent_armor }
      @sub_tour_log << "Touches : #{hits.count} (jet : #{roll_result.rolls} >= #{opponent_armor})"

      roll_saves = "s#{hits.count}d6"
      saves_result = Hazard.from_string roll_saves
      saves = saves_result.rolls.select{ |d| d >= save_value }
      @sub_tour_log << "Sauvegardes : #{saves.count} (jet #{saves_result.rolls} >= #{save_value})"

      final_hits = [hits.count - saves.count, 0].max
      @sub_tour_log << "Pertes = #{final_hits}"

      final_hits
    end

    def check_result
      @sub_tour_log << "Unités restantes à l'attaquant = #{@player_1_units.count}, unités restantes au défenseur = #{@player_2_units.count}, "

      if @player_1_units.empty?
        @sub_tour_log << "L'attaquant gagne."
        return :defender
      elsif @player_2_units.empty?
        @sub_tour_log << 'Le défenseur gagne.'
        return :attacker
      else
        if @player_1_units.count >= @player_2_units.count
          @sub_tour_log << "L'attaquant gagne."
          return :attacker
        else
          @sub_tour_log << 'Le défenseur gagne.'
          return :defender
        end
        @sub_tour_log << 'Egalité.'
        return :equality
      end
    end

    def assign_hits( defender_units, defender, hit )
      if defender.protection > 0
        defender.protection -= hit
        @sub_tour_log << "#{defender.full_name} a une protection. La protection prend #{hit}, protection = #{defender.protection}"
      else
        defender.amount -= hit
        @sub_tour_log << "#{defender.full_name} prend #{hit}, amount = #{defender.amount}"
      end

      if defender.amount <= 0
        @sub_tour_log << "#{defender.full_name} est détruit."
        defender_units.delete( defender )
      end

      defender_units
    end

    def will_attack?( unit )
      ca = unit.unit_data.fight_info.can_attack
      dice = Hazard.d100

      @sub_tour_log << "L'unité à lancé un #{dice} et attaquera si le résultat est en dessous de #{ca}."

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