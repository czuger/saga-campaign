class GangsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_gang, only: [:show, :edit, :update, :destroy]
  before_action :set_campaign, only: [:index, :new]
  before_action :set_player, only: [:create]

  # GET /gangs
  # GET /gangs.json
  def index
    @gangs = Gang.all
  end

  # GET /gangs/1
  # GET /gangs/1.json
  def show
  end

  # GET /gangs/new
  def new
    @gang = Gang.new

    @icons = Dir['app/assets/images/**/*.svg'].map{ |e| e.gsub( 'app/assets/images/', '' ) }.in_groups_of( 7 )
  end

  # GET /gangs/1/edit
  def edit
  end

  # POST /gangs
  # POST /gangs.json
  def create
    new_gang_number = @player.gangs.empty? ? 1 : @player.gangs.maximum( :number )
    @gang = Gang.new({ campaign_id: @campaign.id, player_id: @player.id, icon: params[:icon], number: new_gang_number } )

    Gang.transaction do
      respond_to do |format|
        if @gang.save
          @campaign.logs.create!( data: "#{@player.user.name} a ajouté la bande n°#{new_gang_number}." )

          format.html { redirect_to campaign_player_path( @campaign, @player ), notice: 'La bande a bien été ajoutée.' }
          format.json { render :show, status: :created, location: @gang }
        else
          format.html { render :new }
          format.json { render json: @gang.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  # PATCH/PUT /gangs/1
  # PATCH/PUT /gangs/1.json
  def update
    respond_to do |format|
      if @gang.update(gang_params)
        format.html { redirect_to @gang, notice: 'Gang was successfully updated.' }
        format.json { render :show, status: :ok, location: @gang }
      else
        format.html { render :edit }
        format.json { render json: @gang.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gangs/1
  # DELETE /gangs/1.json
  def destroy
    @gang.destroy
    respond_to do |format|
      format.html { redirect_to campaign_player_path( @campaign, @player ), notice: 'La bande a été correctement supprimée.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def gang_params
      params.permit(:campaign_id, :icon)
    end
end
