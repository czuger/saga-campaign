module GameRules

  class Fight
    def initialize( silent = false )
      @silent = silent
    end

    def go
      load

      1.upto(6).each do |i|
        puts "Tour #{i}" unless @silent

        tour(@player_1_units, @player_2_units )
        tour(@player_2_units, @player_1_units )

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
    def tour(attacker_units, defender_units )
      attacker_units.each do |attacker|
        return if attacker_units.empty? || defender_units.empty?

        if will_attack?(attacker)
          attacker_units, defender_units = perform_attack( attacker_units, defender_units, attacker )
        else
          puts "#{attacker.full_name} n'attaquera pas ce tour." unless @silent
        end

        puts unless @silent
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

      puts "#{attacker.full_name} attaque #{defender.full_name}" unless @silent
      attacking_hits = roll_attack( attacker, defender )

      if @last_attack_cac
        puts "#{defender.full_name} riposte." unless @silent
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
          puts 'Attaque magique' unless @silent
          [ 6, 4, 6 ]
        when :distance
          dice_pool = (attacker.amount * attacker.unit_data.damage.ranged).to_i
          puts "Ranged attack with #{dice_pool} dice" unless @silent
          [ dice_pool, defender.unit_data.armor.ranged, 5 ]
        when :cac
          @last_attack_cac = true

          dice_pool = (attacker.amount * attacker.unit_data.damage.cac).to_i
          puts "Melee attack #{dice_pool} dice" unless @silent
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
      puts "Rolled dice : #{roll_result.rolls}" unless @silent

      hits = roll_result.rolls.select{ |d| d >= opponent_armor }
      puts "Hits : #{hits.count} (#{hits} >= #{opponent_armor})" unless @silent

      roll_saves = "s#{hits.count}d6"
      saves_result = Hazard.from_string roll_saves
      puts "Rolled saves : #{saves_result.rolls}" unless @silent

      saves = saves_result.rolls.select{ |d| d >= save_value }
      puts "Saves : #{saves.count} (#{saves} >= #{save_value})" unless @silent

      final_hits = [hits.count - saves.count, 0].max
      puts "Final hits = #{final_hits}" unless @silent

      final_hits
    end

    def check_result
      puts "Attacker units = #{@player_1_units.count}, defender units = #{@player_2_units.count}, "
      if @player_1_units.empty?
        puts 'Defender win'
        return :defender
      elsif @player_2_units.empty?
        puts 'Attacker win'
        return :attacker
      else
        if @player_1_units.count >= @player_2_units.count
          puts 'Attacker win'
          return :attacker
        else
          puts 'Defender win'
          return :defender
        end
        puts 'Equality'
        return :equality
      end
    end

    def assign_hits( defender_units, defender, hit )
      if defender.protection > 0
        defender.protection -= hit
        puts "#{defender.full_name} has protection. Protection take #{hit}, protection = #{defender.protection}" unless @silent
      else
        defender.amount -= hit
        puts "#{defender.full_name} take #{hit}, amount = #{defender.amount}" unless @silent
      end

      if defender.amount <= 0
        puts "#{defender.full_name} is destroyed" unless @silent
        defender_units.delete( defender )
      end

      defender_units
    end

    def will_attack?( unit )
      ca = unit.unit_data.fight_info.can_attack
      dice = Hazard.d100

      puts "Unit rolled a #{dice} and will attack if roll is below #{ca}" unless @silent

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