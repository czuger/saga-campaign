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

        tour(@player_1_units, @player_2_units )
        tour(@player_2_units, @player_1_units )

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
    def tour(attacker_units, defender_units )
      attacker_units.each do |attacker|

        if !attacker_units.empty? && !defender_units.empty?

          if will_attack?(attacker)
            attacker_units, defender_units = perform_attack( attacker_units, defender_units, attacker )
          else
            @tour_log << "#{attacker.full_name} n'attaquera pas ce tour."
          end

        end

        @tour_log << ''
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

      @tour_log << "#{attacker.full_name} attaque #{defender.full_name}"
      attacking_hits = roll_attack( attacker, defender )

      if @last_attack_cac
        @tour_log << "#{defender.full_name} riposte."
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
          @tour_log << 'Attaque magique'
          
          [ 6, 4, 6 ]
        when :distance
          dice_pool = (attacker.amount * attacker.unit_data.damage.ranged).to_i
          @tour_log << "Ranged attack with #{dice_pool} dice"
          
          [ dice_pool, defender.unit_data.armor.ranged, 5 ]
        when :cac
          @last_attack_cac = true

          dice_pool = (attacker.amount * attacker.unit_data.damage.cac).to_i
          @tour_log << "Melee attack #{dice_pool} dice"
          
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
      @tour_log << "Rolled dice : #{roll_result.rolls}"

      hits = roll_result.rolls.select{ |d| d >= opponent_armor }
      @tour_log << "Hits : #{hits.count} (#{hits} >= #{opponent_armor})"

      roll_saves = "s#{hits.count}d6"
      saves_result = Hazard.from_string roll_saves
      @tour_log << "Rolled saves : #{saves_result.rolls}"

      saves = saves_result.rolls.select{ |d| d >= save_value }
      @tour_log << "Saves : #{saves.count} (#{saves} >= #{save_value})"

      final_hits = [hits.count - saves.count, 0].max
      @tour_log << "Final hits = #{final_hits}"

      final_hits
    end

    def check_result
      puts "Attacker units = #{@player_1_units.count}, defender units = #{@player_2_units.count}, "
      if @player_1_units.empty?
        @tour_log << 'Defender win'
        return :defender
      elsif @player_2_units.empty?
        @tour_log << 'Attacker win'
        return :attacker
      else
        if @player_1_units.count >= @player_2_units.count
          @tour_log << 'Attacker win'
          return :attacker
        else
          @tour_log << 'Defender win'
          return :defender
        end
        @tour_log << 'Equality'
        return :equality
      end
    end

    def assign_hits( defender_units, defender, hit )
      if defender.protection > 0
        defender.protection -= hit
        @tour_log << "#{defender.full_name} has protection. Protection take #{hit}, protection = #{defender.protection}"
      else
        defender.amount -= hit
        @tour_log << "#{defender.full_name} take #{hit}, amount = #{defender.amount}"
      end

      if defender.amount <= 0
        @tour_log << "#{defender.full_name} is destroyed"
        defender_units.delete( defender )
      end

      defender_units
    end

    def will_attack?( unit )
      ca = unit.unit_data.fight_info.can_attack
      dice = Hazard.d100

      @tour_log << "Unit rolled a #{dice} and will attack if roll is below #{ca}"

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