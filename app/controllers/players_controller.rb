class PlayersController < ApplicationController
  before_action :require_logged_in!
  before_action :set_player, except: [:new, :create, :choose_faction_new, :choose_faction_new]

  before_action :set_campaign, only: [:new, :create, :choose_faction_new, :choose_faction_new]
  before_action :set_player_for_campaign, only: [:choose_faction_new, :choose_faction_new]

  # GET /players
  # GET /players.json


  # GET /players/1
  # GET /players/1.json
  def show
    # For future use
  end

  # GET /players/new
  def new
    @player = Player.new

    # All players but not those already in campaign.
    @players = User.where.not( id: @campaign.players.map{ |p| p.user_id } )
  end

  # POST /players
  # POST /players.json
  def create

    Campaign.transaction do
      new_players_creation_result = true
      params['players'].each do |player|
        user = User.find( player )
        new_players_creation_result &= Player.create_new_player( @campaign, user )

        if @campaign.players.count >= @campaign.max_players
          @campaign.players_choose_faction!
        end
      end

      respond_to do |format|
        if new_players_creation_result
          format.html { redirect_to campaigns_path, notice: t( '.success' ) }

        else
          format.html { render :new }

        end
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: t( '.success' ) }
    end
  end

  def schedule_movements_edit
    @player = Player.find( params[:player_id] )
    @gangs = @player.gangs.where.not( gang_destroyed: true ).where.not( retreating: true ).order( :movement_order )

    @forbidden_movements = GameRules::Factions.opponent_recruitment_positions( @player )
  end

  def schedule_movements_save
    Gang.transaction do

      gang_order_hash = Hash[ params[:gangs_order].split( ',' ).each_with_index.map{ |e, i| [ e.strip.to_i, i ] } ]

      @player.gangs.includes( :campaign ).where( id: gang_order_hash.keys ).each do |gang|
        gang.movement_order = gang_order_hash[ gang.id ] + 1
        gang.movements = gang_movements_array( gang.id )
        gang.save!
      end

      validate_movements = params.has_key?( :validate )

      if validate_movements
        @player.movements_orders_finalized = true
        @player.save!
      end

      redirect_to campaign_path( @campaign ), notice: I18n.t( 'players.notices.modification_success' )
    end
  end

  def choose_faction_new
    # Check if we have been invited in this campaign
    # @involved_player = @campaign.players.where( user_id: current_user.id ).take

    unless @player.faction
      # For now the mechanism is for two players only
      already_selected_factions = @campaign.players.pluck( :faction ).compact
      selected_faction = already_selected_factions.first

      @selected_bloc = GameRules::Factions::FACTIONS_TO_BLOCS[ selected_faction&.to_sym ]

      # @select_factions_options = GameRules::Factions.new.faction_select_options(
      #   GameRules::Factions::FACTIONS_BLOCS[ selected_bloc ] )
    end
  end

  def choose_faction_save
    @player.faction = params[:faction]

    Player.transaction do
      @player.save!

      # If all players has a faction
      if @campaign.players.where( faction: nil ).count == 0

        # Choose a random initiative order for players and save it
        @campaign.player_ids.shuffle.each_with_index do |player_id, i|
          p = Player.find( player_id )
          p.initiative = i
          p.controls_points = GameRules::Factions.initial_control_points( @campaign, p )
          p.save!
        end

        @campaign.players_first_hire_and_move!
      end
    end

    redirect_to campaigns_path
  end

  def initiative_bet_edit
  end

  def initiative_bet_save
    Player.transaction do
      @player.initiative_bet = params[ :pp ].to_i
      @player.save!

      if @campaign.players.where( initiative_bet: nil ).reload.count == 0
        set_initiative!
        next_turn!
      end

      redirect_to campaign_path( @campaign ), notice: I18n.t( 'players.notices.modification_success' )
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def player_params
    params.permit(:campaign_id, :player )
  end

  def gang_movements_array( gang_id )
    gang_id = gang_id.to_s.freeze
    [ params[:gang_movement]['1'.freeze][gang_id], params[:gang_movement]['2'.freeze][gang_id] ].reject{ |e| e&.empty? }
  end

  def set_initiative!
    # This will work for 2 players only

    tmp_players = []
    @campaign.players.includes( :user ).order( 'initiative_bet DESC' ).each do |player|
      @campaign.logs.create!( data: I18n.t( 'log.initiative.bet', name: player.user.name, count: player.initiative_bet ) )
      tmp_players << player
    end
    new_first_player, new_second_player = tmp_players

    if new_first_player.initiative_bet == new_second_player.initiative_bet
      new_first_player, new_second_player = @campaign.players.includes( :user ).order( :initiative ).to_a
    end

    new_first_player.initiative = 1
    new_first_player.pp -= new_first_player.initiative_bet
    new_first_player.initiative_bet = nil
    new_first_player.save!
    @campaign.logs.create!( data: I18n.t( 'log.initiative.order', name: new_first_player.user.name, count: new_first_player.initiative ) )

    new_second_player.initiative = 2
    new_second_player.pp -= new_second_player.initiative_bet
    new_second_player.initiative_bet = nil
    new_second_player.save!
    @campaign.logs.create!( data: I18n.t( 'log.initiative.order', name: new_second_player.user.name, count: new_second_player.initiative ) )

  end

  # The following methods should be moved elsewhere
  def next_turn!
    @campaign.gangs.update_all( retreating: false )
    @campaign.players.update_all( maintenance_required: false )

    @campaign.turn += 1
    @campaign.players_hire_and_move!

    @campaign.save!
  end

end
