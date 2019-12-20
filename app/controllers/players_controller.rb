class PlayersController < ApplicationController
  # before_action :set_player, only: [:show, :edit, :update, :destroy]

  before_action :require_logged_in!
  before_action :set_campaign

  # GET /players
  # GET /players.json
  def index
    @players = User.all
  end

  # GET /players/1
  # GET /players/1.json
  def show
  end

  # GET /players/new
  def new
    @player = Player.new
    @players = User.all
  end

  # POST /players
  # POST /players.json
  def create

    Campaign.transaction do
      new_players_creation_result = true
      params['players'].each do |player|
        user = User.find( player )
        new_players_creation_result &= Player.create( user_id: player, campaign_id: @campaign.id )
        @campaign.logs.create!( data: "Joueur #{user.name} ajouté à la campagne.")
      end

      respond_to do |format|
        if new_players_creation_result
          format.html { redirect_to @campaign, notice: 'Player was successfully created.' }
          format.json { render :show, status: :created, location: @player }
        else
          format.html { render :new }
          format.json { render json: @player.errors, status: :unprocessable_entity }
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
      format.json { head :no_content }
    end
  end

  private

    def set_campaign
      @campaign = Campaign.find(params[:campaign_id] )
      @player = Player.find_by_campaign_id_and_user_id( @campaign.id, current_user.id )
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.permit(:campaign_id, :player )
    end
end
