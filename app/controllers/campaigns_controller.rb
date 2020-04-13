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
    @campaigns = current_user.participating_campaigns
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
        format.html { redirect_to new_campaign_player_path( @campaign ), notice: t( 'creation_success.f', item: 'La campagne' ) }
      else
        format.html { render :new }
      end
    end

  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to @campaign, notice: t( 'update_success.f', item: 'La campagne' ) }
        
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
      format.html { redirect_to campaigns_url, notice: t( 'deletion_success.f', item: 'La campagne' ) }
      
    end
  end

  def initiative_edit
  end

  def initiative_save
    new_order_hash = Hash[ params[ :new_order ].values ]

    Player.transaction do
      @campaign.players.includes(:user).each do |player|
        player.initiative = new_order_hash[ player.id.to_s ].to_i
        player.save!
      end
    end
  end

  def resolve_movements
    # We check if all players have validated their movements
    # if validate_movements && @campaign.players.where( movements_orders_finalized: false ).count <= 1

    GameRules::Movements.new( @campaign ).run!

    # TODO : run all movement with combats directly
    # TODO : switch campaign state

    # FOCUS ON CAMPAIGN MECHANISM FIRST. DO NOT INCLUDE COMBAT.

    redirect_to campaign_show_movements_path( @campaign )
  end

  def show_movements
    @movements = @campaign.movements_results.includes( :gang, { player: :user } ).order( :id )
    @gangs = @campaign.gangs.joins( :player ).includes( { player: :user } ).order( 'players.initiative', :movement_order )
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def campaign_params
    params.require(:campaign).permit(:user_id, :name, :faction)
  end

  def create_new_campaign
    Campaign.transaction do
      result = @campaign.save
      result &&= @campaign.logs.create( data: I18n.t( 'log.campaign.created' ) )
      result &&= @campaign.players.create( user_id: current_user.id, pp: GameRules::Factions::START_PP, controls_points: [] )
      result && @campaign.logs.create( data: I18n.t( 'log.campaign.created', name: current_user.name ) )
    end
  end

end
