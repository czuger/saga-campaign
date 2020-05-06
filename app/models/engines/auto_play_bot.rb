module Engines

  class AutoPlayBot

    def initialize
      @session = ActionDispatch::Integration::Session.new( Rails.application )
      @session.host = 'localhost:3000'
      @session.https!

      auth_params = { email: :foo, name: :foo }
      @session.get '/auth/developer/callback', params: auth_params

      @user = User.find_by_uid_and_provider( :foo, :developer )
      players = @user.players.where.not( faction: nil ).reject{ |p| p.campaign.campaign_finished? }
      @players_ostruct_array = players.map{ |p| OpenStruct.new( status: :move, initiative_bet: false, player: p ) }
    end

    def run
        loop do

          @players_ostruct_array.each do |player_ostruct|
            payer_ostruct = check_status( player_ostruct )

            if player_ostruct.status != :waiting
              move( player_ostruct )

              player_ostruct = reset_status( player_ostruct )
            end
          end

          break

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

      locations_memories = []
      gangs_order = []
      scheduled_movements = {}

      player = player_ostruct.player

      # p player
      # p player.gangs.all

      player.gangs.each_with_index do |gang, i|
        puts "Moving gang #{gang.name}"

        locations_memories << gang.location

        gangs_order << gang.id

        forbidden_movements = GameRules::Factions.opponent_recruitment_positions( player )

        target = ( GameRules::Map.available_movements( gang.location ) - forbidden_movements - locations_memories ).sample
        puts "Moving gang #{gang.name} to #{gang.movements}"

        if target
          scheduled_movements[ gang.id ] = target
        end

      end

      @session.process( :get, "/players/#{player.id}/schedule_movements_edit" )
      # puts @session.response.body
      csrf_token = @session.session.to_hash['_csrf_token']

      params = {
        gang_movement: {
          '1' => scheduled_movements,
          '2' => Hash[ gangs_order.map{ |e| [e, ''] } ] },
        gangs_order: gangs_order.join( ',' ),
        authenticity_token: csrf_token
      }

      @session.process( :post, "/players/#{player.id}/schedule_movements_save", params: params )
      # puts @session.response.body
        # player.movements_orders_finalized = true
      # player.initiative_bet = 2
      # player.save!

    end

  end

end