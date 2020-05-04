module Engines

  class AutoPlayBot

    def initialize
      @user = User.find_by_name( :foo )
      players = @user.players.where.not( faction: nil ).reject{ |p| p.campaign.campaign_finished? }
      @players_ostruct_array = players.map{ |p| OpenStruct.new( status: :move, initiative_bet: false, player: p ) }
    end

    def run
        loop do

          @players_ostruct_array.each do |player_ostruct|
            player_ostruct = check_status( player_ostruct )

            if player_ostruct.status != :waiting
              move( player_ostruct )

              player_ostruct = reset_status( player_ostruct )
            end
          end

          sleep( 3 )
      end
    end

    private

    def check_status( player_ostruct )

      player_ostruct.player.reload
      campaign = player_ostruct.player.campaign

      player_ostruct.initiative_bet = true if campaign.bet_for_initiative?

      if player_ostruct.initiative_bet
        player_ostruct.status = :move if campaign.hiring_and_movement_schedule? || campaign.first_hiring_and_movement_schedule?
      end

      # p player_ostruct
      # p player_ostruct.player.campaign.aasm_state
      # puts

      player_ostruct
    end

    def reset_status( player_ostruct )
      player_ostruct.status = :waiting
      player_ostruct.initiative_bet = false
      player_ostruct
    end

    def move( player_ostruct )
      puts "Movement for #{player_ostruct.player.user.name}"
      used_second_movements = []

      player = player_ostruct.player

      # p player
      # p player.gangs.all

      player.gangs.each_with_index do |g, i|
        puts "Moving gang #{g.name}"

        used_second_movements << g.location

        g.movement_order = i + 1

        forbidden_movements = GameRules::Factions.opponent_recruitment_positions( player )

        g.movements = []
        g.movements << ( GameRules::Map.available_movements( g.location ) - forbidden_movements ).sample

        available_second_movements = GameRules::Map.available_movements( g.movements[0] ) - used_second_movements - forbidden_movements
        second_movement = available_second_movements.sample
        used_second_movements << second_movement
        g.movements << second_movement
        g.save!

        puts "Moving gang #{g.name} to #{g.movements}"
      end

      player.movements_orders_finalized = true
      player.initiative_bet = 2
      player.save!

    end

  end

end