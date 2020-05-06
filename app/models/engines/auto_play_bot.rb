module Engines

  class AutoPlayBot

    def initialize
      @session = ActionDispatch::Integration::Session.new( Rails.application )
      @session.host = 'localhost:3000'
      @session.https!

      auth_params = { email: :foo, name: :foo }
      @session.get '/auth/developer/callback', params: auth_params

      @user = User.find_by_uid_and_provider( :foo, :developer )
      # @players_ostruct_array = @players.map{ |p| OpenStruct.new( status: :move, initiative_bet: false, player: p ) }
    end

    def run
        loop do
          load_players

          @players_needing_faction_choice.each{ |p| choose_faction( p ) }
          @players_needing_action.each{ |p| player_action( p ) }

          sleep( 3 )
      end
    end

    private

    def player_action( player )
      campaign = player.reload.campaign

      if campaign.waiting_for_players_to_choose_their_faction?
        choose_faction( player )
      end

    end

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

    def choose_faction( player )
      puts "Faction choice request detected for campaign #{player.campaign.name}."

      csrf_interaction(
        "/players/#{player.campaign_id}/choose_faction_new", :patch,
        "/players/#{player.id}/choose_faction_save",
        faction: :royaumes
      )
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

      csrf_interaction(
        "/players/#{player.id}/schedule_movements_edit", :post,
        "/players/#{player.id}/schedule_movements_save",
        gang_movement: {
          '1' => scheduled_movements,
          '2' => Hash[ gangs_order.map{ |e| [e, ''] } ] },
        gangs_order: gangs_order.join( ',' )
      )

    end

    def load_players
      basic_players_request = @user.players.reload.joins( :campaign ).where( "campaigns.aasm_state != 'campaign_finished'")

      @players_needing_faction_choice = basic_players_request.where( faction: nil )
      @players_needing_action = basic_players_request.where.not( faction: nil )
    end

    def csrf_interaction(get_url, method, interaction_url, interaction_params )
      @session.process( :get, get_url )
      csrf_token = @session.session.to_hash['_csrf_token']

      p csrf_token

      interaction_params[ :authenticity_token ] = csrf_token

      @session.process( method, interaction_url, params: interaction_params )
    end

  end

end