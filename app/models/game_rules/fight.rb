module GameRules

  class Fight
    def initialize( silent = false )
      @silent = silent
    end

    def go
      load

      1.upto(6).each do |i|
        puts "Tour #{i}" unless @silent

        round( @player_1_units, @player_2_units )
        round( @player_2_units, @player_1_units )

        break if @player_1_units.empty? || @player_2_units.empty?
      end

      check_result
    end

    def round( attacker_units, defender_units )
      attacker_units.each do |unit|
        return if attacker_units.empty? || defender_units.empty?

        puts "Attacking unit : #{unit.libe} #{unit.weapon}" unless @silent
        if will_attack?(unit)
          target = get_target( defender_units )

          puts "Will attack : #{target.libe} #{target.weapon}" unless @silent

          dice_pool = nil
          opponent_armor = nil
          save_value = nil
          # Probably a OpenHash conversion issue. == true is required
          if( unit.unit_data.fight_info.distance == true )
            dice_pool = (unit.amount * unit.unit_data.damage.ranged).to_i
            opponent_armor = target.unit_data.armor.ranged
            save_value = 5
            puts "Ranged attack with #{dice_pool} dice" unless @silent
          else
            dice_pool = (unit.amount * unit.unit_data.damage.cac).to_i
            opponent_armor = target.unit_data.armor.cac
            save_value = 4
            puts "Melee attack #{dice_pool} dice" unless @silent
          end

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

          unless assign_hits( target, final_hits )
            puts "#{target.full_name} is destroyed" unless @silent
            defender_units.delete( target )
          end
        end

        puts unless @silent
      end
    end

    private

    def load
      @player_1 = Gang.find( 1 )
      @player_2 = Gang.find( 2 )

      @player_1_units = @player_1.units.to_a
      @player_2_units = @player_2.units.to_a
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

    def assign_hits( unit, hit )
      if unit.protection > 0
        unit.protection -= hit
        puts "#{unit.full_name} has protection. Protection take #{hit}, protection = #{unit.protection}" unless @silent
      else
        unit.amount -= hit
        puts "#{unit.full_name} take #{hit}, amount = #{unit.amount}" unless @silent
      end

      return false if unit.amount <= 0
      true
    end

    def will_attack?( unit )
      ca = unit.unit_data.fight_info.can_attack
      dice = Hazard.d100

      puts "Unit rolled a #{dice} and will attack if roll is below #{ca}" unless @silent

      if dice <= ca
        puts 'Unit will attack.' unless @silent
        return true
      end

      puts 'Unit will not attack.' unless @silent
      return false
    end

    def get_target( defender_units )
      wt = WeightedTable.new( floating_points: true )

      units = defender_units.map{ |u| [ u.unit_data.fight_info.being_targeted, u ] }
      wt.from_weighted_table( units)

      wt.sample
    end
  end

end