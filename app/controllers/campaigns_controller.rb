class CampaignsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_campaign, except: [ :index, :new, :create ]
  before_action :set_player_for_campaign, only: [ :show, :show_movements ]

  def controlled_points
    @map = GameRules::Map.new
  end

  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = current_user.participating_campaigns.includes({ players: :user }, { winner: :user }).order( 'id DESC' )
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    @players = @campaign.players.includes( :user ).all
    @logs = @campaign.logs.includes( { player: :user } ).order( 'updated_at DESC' ).paginate( page: params[:page] )
    @movements_finalized = @campaign.players.where( movements_orders_finalized: false ).count == 0
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
    @campaign.name = GameRules::UnitNameGenerator.generate_unique_campaign_name
  end

  # GET /campaigns/1/edit
  def edit
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.user = current_user

    respond_to do |format|
      if create_new_campaign
        format.html { redirect_to new_campaign_player_path( @campaign ), notice: t( '.success' ) }
      else
        format.html { render :new, error: t( '.failure' ) }
      end
    end

  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to @campaign, notice: t( '.success' ) }
        
      else
        format.html { render :edit }
        
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to campaigns_url, notice: t( '.success' ) }
      
    end
  end

  def initiative_edit
  end

  def resolve_movements
    # We check if all players have validated their movements
    # if validate_movements && @campaign.players.where( movements_orders_finalized: false ).count <= 1

    Campaign.transaction do
      interceptions_count = GameRules::Movements.new( @campaign ).run!

      if interceptions_count == 0 || @campaign.campaign_mode.to_sym == :test
        after_move_and_combats
      else
        @campaign.to_combat_phase!
        redirect_to campaigns_path
      end
    end
  end

  def show_movements
    @movements = @campaign.movements_results.includes( :gang, { player: :user } ).order( :id )
    @gangs = @campaign.gangs.where.not( movement_order: nil ).joins( :player ).includes( { player: :user } ).order( 'players.initiative', :movement_order )
  end

  def show_victory_status
    @vp_status = @campaign.victory_points_histories.includes( { player: :user } ).order( 'turn DESC, player_id' )
    @vp_sums = @campaign.victory_points_histories.joins( { player: :user } ).group( 'users.name' ).sum( :points_total )
  end

  def input_combats_edit
    @fights = @campaign.movements_results.where( interception: true ).includes(
      { gang: { player: :user } }, { intercepted_gang: { player: :user } } )
  end

  private

  def after_move_and_combats
    cp_manager = GameRules::ControlPoints.new( @campaign )

    cp_manager.set_control_of_locations!
    cp_manager.gain_pp_for_control_points!
    cp_manager.check_maintenance_cost_for_all_player!

    if cp_manager.maintenance_required?
      @campaign.require_troop_maintenance!
      redirect_to campaigns_path
    else
      cp_manager.loose_pp_for_mainteance!

      compute_points_for_players!

      if check_for_victory!
        @campaign.terminate_campaign!
        redirect_to campaigns_path
      else
        @campaign.players_bet_for_initiative!
        redirect_to campaign_show_movements_path( @campaign )
      end
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def campaign_params
    params.require(:campaign).permit(:user_id, :name, :faction, :campaign_mode)
  end

  def create_new_campaign
    Campaign.transaction do
      result = @campaign.save

      # p result
      # p @campaign
      # p @campaign.errors

      raise @campaign.errors.inspect unless result

      @player = Player.create_new_player( @campaign, current_user )
      result &&= @campaign.add_log( @player, :campaign, :created )

      result && @player.errors.empty?
    end
  end

  def check_for_victory!
    if @campaign.turn == 6
      players_sums = @campaign.victory_points_histories.group( :player_id ).sum( :points_total )

      max_sum = players_sums.values.max
      potential_winners = players_sums.select{ |_, v| v == max_sum }
      potential_winners = potential_winners.keys
    else
      @campaign.players.each do |player|
        potential_winners ||= []
        potential_winners << player.id if GameRules::Map.prestigious_locations_count( player ) >= 4
      end
    end

    if potential_winners.count > 0
      if potential_winners.count == 1
        @campaign.winner = Player.find( potential_winners.first )
      else
        winner = Player.where( id: potential_winners ).order( :initiative ).first
        @campaign.winner = winner
      end

      return true
    end

    false
  end

  def compute_points_for_players!
    @campaign.players.each do |player|
      _controlled_locations = player.controls_points.select{ |p| p =~ /P./ }
      VictoryPointsHistory.create!(
        player: player, turn: @campaign.turn, controlled_locations: _controlled_locations,
        points_total: _controlled_locations.count )
    end
  end

end
