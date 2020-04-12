namespace :fill_db do

  desc 'Opponents move gangs'
  task opponent_move_gangs: :environment do

    Player.where( user_id: 2 ).where.not( faction: nil ).each do |p|
      p.gangs.each_with_index do |g, i|
        g.movement_order = i

        g.movements = []
        g.movements << GameRules::Map.available_movements( g.location ).sample
        g.movements << GameRules::Map.available_movements( g.movements[0] ).sample
        g.save!

        puts "Moving gang #{g.name}"
      end

      p.movements_orders_finalized = true
      p.save!
    end
  end

  desc 'Opponents create gangs'
  task opponent_create_gangs: :environment do

    original_icons = %w( caesar.svg laurels.svg spartan.svg )
    original_locations = GameRules::Factions::FACTIONS_STARTING_POSITIONS['order']

    Player.where( user_id: 2 ).where.not( faction: nil ).each do |p|
      icons = original_icons.dup
      locations = original_locations.dup

      1.upto( 3 ).each do |gang_id|
        g = Gang.create( campaign: p.campaign, player: p, icon: "royaumes/#{icons.shift}", points: 6,
                         number: gang_id, location: locations.shift, faction: 'royaumes',
                         name: GameRules::UnitNameGenerator.generate_unique_unit_name( p.campaign ) )

        1.upto( 6 ).each do
          Unit.create!( gang: g, libe: 'guerriers', weapon: '-', amount: 8, points: 1,
                        name: GameRules::UnitNameGenerator.generate_unique_unit_name( p.campaign ) )
        end
      end
    end
  end

  desc 'Opponents choose factions'
  task opponent_choose_faction: :environment do

    Player.where( user_id: 2, faction: nil ).each do |p|
      p p
      p.faction = 'royaumes'
      p.save!
    end
  end

end