require 'active_record'
require '../app/models/application_record'
require 'hazard'

require_relative '../app/models/gang'
require_relative '../app/models/Rules/unit'
require_relative '../app/models/unit'

db = YAML.load_file( '../config/database.yml' )['development']
db['database'] = '../' + db['database']
db['pool'] = 5

ActiveRecord::Base.establish_connection(db )

class Fight
  def initialize
    @player_1 = Gang.find( 1 )
    @player_2 = Gang.find( 2 )

    @units = Rules::Unit.new( unit_file_path: '../data/units.yaml' )
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
      puts "#{unit.libe} #{unit.weapon}"
      if will_attack?(unit)
        target = get_target( defender )

        puts "Will attack : #{target.libe} #{target.weapon}"


      end

      puts
    end
  end

  private

  def will_attack?( unit )
    ca = @units.data[unit.libe][unit.weapon][:fight_info][:can_attack]
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

    units = defender.units.map{ |u| [ @units.data[u.libe][u.weapon][:fight_info][:being_targeted], u ] }
    wt.from_weighted_table( units)

    wt.sample
  end
end

Fight.new.go
