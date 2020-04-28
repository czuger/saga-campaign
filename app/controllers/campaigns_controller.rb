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
    @campaigns = current_user.participating_campaigns.order( 'id DESC' )
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    @players = @campaign.players.includes( :user ).all
    @logs = @campaign.logs.order( 'updated_at DESC' ).paginate( page: params[:page] )
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
      GameRules::Movements.new( @campaign ).run!
      GameRules::ControlPoints.new( @campaign ).set_control_of_locations!

      redirect_to campaign_show_movements_path( @campaign )
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

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def campaign_params
    params.require(:campaign).permit(:user_id, :name, :faction)
  end

  def create_new_campaign
    Campaign.transaction do
      result = @campaign.save

      # p result
      # p @campaign
      # p @campaign.errors

      raise @campaign.errors.inspect unless result

      result &&= @campaign.logs.create( data: I18n.t( 'log.campaign.created' ) )
      @player = Player.create_new_player( @campaign, current_user )
      result && @player.errors.empty?
    end
  end

end
