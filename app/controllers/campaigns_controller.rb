class CampaignsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_campaign, except: [ :index, :new, :create ]
  # before_action :set_player, only: [ :show ]

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
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)

    Campaign.transaction do
      respond_to do |format|
        if @campaign.save

          @campaign.logs.create!( data: 'Campagne crée' )

          Player.create!( user_id: current_user.id, campaign_id: @campaign.id )
          @campaign.logs.create!( data: "Joueur #{current_user.name} ajouté à la campagne.")

          format.html { redirect_to new_campaign_player_path( @campaign ), notice: t( 'creation_success.f', item: 'La campagne' ) }
        else
          format.html { render :new }
        end
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

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      params.require(:campaign).permit(:user_id, :name)
    end
end
