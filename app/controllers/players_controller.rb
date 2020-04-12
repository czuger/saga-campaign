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
    @localisations = GameRules::Map.new.localisations
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
        new_players_creation_result &= Player.create(
          user_id: player, campaign_id: @campaign.id, pp: GameRules::Factions::START_PP )

        @campaign.logs.create!( data: "Joueur #{user.name} ajouté à la campagne.")

        if @campaign.players.count >= @campaign.max_players
          @campaign.players_choose_faction!
        end
      end

      respond_to do |format|
        if new_players_creation_result
          format.html { redirect_to campaigns_path, notice: 'Joueur correctement ajouté.' }

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
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }

    end
  end

  def modify_pp
    # TODO : use set_player once it is fixed.

    player = Player.find( params[:player_id] )
    player.pp = params[:player][:pp]
    player.save!

    player.campaign.logs.create!( data: "#{player.user.name} a modifié son nombre de pp : #{player.pp}." )
  end

  def schedule_movements_edit
    @player = Player.find( params[:player_id] )
    @gangs = @player.gangs.order( :movement_order )

    # @loc = GameRules::Map.new.localisations
  end

  def schedule_movements_save
    Gang.transaction do
      params[:gangs_order].split( ',' ).each_with_index do |gang_id, index|

        gang_id = gang_id.strip

        gang = Gang.find( gang_id )
        raise "Player #{@player.inspect} is not allowed to modify gang #{gang.inspect}" unless gang.player_id == @player.id

        gang.movement_order = index
        gang.movements = [params[:gang_movement]['1'.freeze][gang_id], params[:gang_movement]['2'.freeze][gang_id]]
        gang.movements.reject!{ |e| e.empty? }
        gang.save!
      end

      validate_movements = params.has_key?( :validate )

      if validate_movements
        @player.movements_orders_finalized = true
        @player.save!
      end

      # We check if all players have validated their movements
      if validate_movements && @campaign.players.where( movements_orders_finalized: false ).count <= 1

        GameRules::Movements.new( @campaign ).run!

        # TODO : run all movement with combats directly
        # TODO : reset movements_orders_finalized and movements orders
        # TODO : switch campaign state

        # FOCUS ON CAMPAIGN MECHANISM FIRST. DO NOT INCLUDE COMBAT.

        redirect_to campaign_show_movements_path( @campaign ), notice: I18n.t( 'players.notices.modification_success' )
      else
        redirect_to player_schedule_movements_edit_path( @player ), notice: I18n.t( 'players.notices.modification_success' )
      end
    end
  end

  def choose_faction_new
    # Check if we have been invited in this campaign
    # @involved_player = @campaign.players.where( user_id: current_user.id ).take

    unless @player.faction
    # For now the mechanism is for two players only
    already_selected_factions = @campaign.players.pluck( :faction ).compact
    selected_faction = already_selected_factions.first

    @selected_bloc = GameRules::Factions::FACTIONS_TO_BLOCS[ selected_faction ]

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
          p.save!
        end
        @campaign.players_first_hire_and_move!
      end
    end

    redirect_to campaigns_path
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.permit(:campaign_id, :player )
    end
end
