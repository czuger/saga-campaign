require 'active_record'
require 'hazard'

require_relative '../app/models/application_record'
require_relative '../app/models/gang'
require_relative '../app/models/Rules/unit'
require_relative '../app/models/unit'

db = YAML.load_file( 'config/database.yml' )['development']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

class Fight
  def initialize
    @player_1 = Gang.find( 1 )
    @player_2 = Gang.find( 2 )
  end

  def go
    1.upto(6).each do |i|
      puts "Tour #{i}"

      round( @player_1, @player_2 )
      round( @player_2, @player_1 )
    end
  end

  def round( attacker, defender )
    attacker.units.each do |unit|
      puts "Attacking unit : #{unit.libe} #{unit.weapon}"
      if will_attack?(unit)
        target = get_target( defender )

        puts "Will attack : #{target.libe} #{target.weapon}"

        dice_pool = nil
        opponent_armor = nil
        save_value = nil
        # Probably a OpenHash conversion issue. == true is required
        if( unit.unit_data.fight_info.distance == true )
          dice_pool = (unit.amount * unit.unit_data.damage.ranged).to_i
          opponent_armor = target.unit_data.armor.ranged
          save_value = 5
          puts "Ranged attack with #{dice_pool} dice"
        else
          dice_pool = (unit.amount * unit.unit_data.damage.cac).to_i
          opponent_armor = target.unit_data.armor.cac
          save_value = 4
          puts "Melee attack #{dice_pool} dice"
        end

        roll_string = "s#{dice_pool}d6"
        roll_result = Hazard.from_string roll_string
        puts "Rolled dice : #{roll_result.rolls}"

        hits = roll_result.rolls.select{ |d| d >= opponent_armor }
        puts "Hits : #{hits.count} (#{hits} >= #{opponent_armor})"

        roll_saves = "s#{hits.count}d6"
        saves_result = Hazard.from_string roll_saves
        puts "Rolled saves : #{saves_result.rolls}"

        saves = saves_result.rolls.select{ |d| d >= save_value }
        puts "Saves : #{saves.count} (#{saves} >= #{save_value})"

        final_hits = hits.count - saves.count
        puts "Final hits = #{final_hits}"
      end

      puts
    end
  end

  private

  def will_attack?( unit )
    ca = unit.unit_data.fight_info.can_attack
    dice = Hazard.d100

    puts "Unit rolled a #{dice} and will attack if roll is below #{ca}"

    if dice <= ca
      puts 'Unit will attack.'
      return true
    end

    puts 'Unit will not attack.'
    return false
  end

  def get_target( defender )
    wt = WeightedTable.new( floating_points: true )

    units = defender.units.map{ |u| [ u.unit_data.fight_info.being_targeted, u ] }
    wt.from_weighted_table( units)

    wt.sample
  end
end

Fight.new.go
