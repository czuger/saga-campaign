module Engines

  class AutoPlayBot

    def initialize
      @session = ActionDispatch::Integration::Session.new( Rails.application )
      @session.host = 'localhost:3000'
      @session.https!

      auth_params = { email: :foo, name: :foo }
      @session.get '/auth/developer/callback', params: auth_params

      @user = User.find_by_uid_and_provider( :foo, :developer )

      @units_to_hire = [
        ['seigneur', '-', 1], ['monstre', 'behemoth', 1], ['creatures', 'bipedes', 2], ['gardes', 'arme_lourde', 4],
        ['guerriers', '-', 8], ['guerriers', '-', 8], ['levees', 'arc_ou_fronde', 12]
      ].freeze

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

      if campaign.first_hiring_and_movement_schedule?
        unless player.movements_orders_finalized
          first_hiring( player )
          move( player )
        end
      end

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

    def first_hiring( player )
      puts "Will hire first gangs for campaign  #{player.campaign.name}"
      GameRules::Factions::FACTIONS_STARTING_POSITIONS[:order].each do |location|
        hire_gang( player, location, 6 )
      end
    end

    def hire_gang( player, location, max_size )
      next_free_icon = player.remaining_icons_list.first

      uth = @units_to_hire[ 0 .. max_size ]

      csrf_interaction(
        "/players/#{player.id}/gangs/new", :post,
        "/players/#{player.id}/gangs",
        gang: {
          icon: next_free_icon, faction: 'royaumes', number: (player.gangs.maximum( :number ) || 0 )+1, location: location,
          name: GameRules::UnitNameGenerator.generate_unique_unit_name( player.campaign ) }
      )

      created_gang_id = player.gangs.maximum( :id )

      uth.each do |unit|
        csrf_interaction(
          "/gangs/#{created_gang_id}/units/new", :post,
          "/gangs/#{created_gang_id}/units",
          unit: { libe: unit[0], amount: unit[2], points: 1, weapon: unit[1] }
        )
      end
    end

    def move( player )
      puts "Movement for #{player.user.name}"

      locations_memories = []
      gangs_order = []
      scheduled_movements = {}

      player.gangs.each_with_index do |gang, i|
        puts "Moving gang #{gang.name}"

        locations_memories << gang.location

        gangs_order << gang.id

        forbidden_movements = GameRules::Factions.opponent_recruitment_positions( player )

        target = ( GameRules::Map.available_movements( gang.location ) - forbidden_movements - locations_memories ).sample

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
        gangs_order: gangs_order.join( ',' ),
        validate: true
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

      # p csrf_token

      interaction_params[ :authenticity_token ] = csrf_token

      @session.process( method, interaction_url, params: interaction_params )
    end

  end

end