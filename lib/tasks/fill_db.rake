namespace :fill_db do

  desc 'Opponents move gangs'
  task opponent_move_gangs: :environment do

    Player.where( user_id: 2 ).where.not( faction: nil ).each do |p|

      used_second_movements = []

      p.gangs.each_with_index do |g, i|
        g.movement_order = i + 1

        g.movements = []
        g.movements << GameRules::Map.available_movements( g.location ).sample

        available_second_movements = GameRules::Map.available_movements( g.movements[0] ) - used_second_movements
        second_movement = available_second_movements.sample
        used_second_movements << second_movement
        g.movements << second_movement
        g.save!

        puts "Moving gang #{g.name} to #{g.movements}"
      end

      p.movements_orders_finalized = true
      p.initiative_bet = 2
      p.save!
    end
  end

  desc 'Opponents create gangs'
  task opponent_create_gangs: :environment do

    original_icons = %w( caesar.svg laurels.svg spartan.svg )
    original_locations = GameRules::Factions::FACTIONS_STARTING_POSITIONS['order']

    units = [
      ['seigneur', '-', 1], ['monstre', 'behemoth', 1], ['creatures', 'bipedes', 2], ['gardes', 'arme_lourde', 4],
      ['guerriers', '-', 8], ['guerriers', '-', 8], ['levees', 'arc_ou_fronde', 12]
    ]

    Player.where( user_id: 2 ).where.not( faction: nil ).each do |p|
      icons = original_icons.dup
      locations = original_locations.dup

      1.upto( 3 ).each do |gang_id|
        g = Gang.create( campaign: p.campaign, player: p, icon: "royaumes/#{icons.shift}", points: 6,
                         number: gang_id, location: locations.shift, faction: 'royaumes',
                         name: GameRules::UnitNameGenerator.generate_unique_unit_name( p.campaign ) )

        units.each do |unit_type|
          Unit.create!( gang: g, libe: unit_type[0], weapon: unit_type[1], amount: unit_type[2], points: 1,
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
      p.controls_points = GameRules::Factions.initial_control_points( p.campaign, p )
      p.save!
    end
  end

end
