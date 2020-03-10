class GangsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_gang, only: [:show, :edit, :update, :destroy]
  before_action :set_campaign, only: [:new]
  before_action :set_player, only: [:create, :index]
  before_action :set_gang_for_modification, only: [:change_location]

  def change_location
    @gang.location = params[:location]
    @gang.save!
  end

  # GET /gangs
  # GET /gangs.json
  def index
    @gangs = Gang.find_by_campaign_id_and_player_id( @campaign, @player )
  end

  # GET /gangs/1
  # GET /gangs/1.json
  def show
  end

  # GET /gangs/new
  def new
    @gang = Gang.new

    @icons = {}
    Dir['app/assets/images/gangs_icons/*'].each do |icons_path|
      @icons_set = File.basename(icons_path)
      # p icons_set
      @icons[@icons_set] = Dir["#{icons_path}/*.svg"].map{ |e| e.gsub( 'app/assets/images/', '' ) } # .in_groups_of( 7 )
    end

    # p @icons

    @select_factions_options = Rules::Factions.new.select_options_array
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

        else
          format.html { render :new }

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

      else
        format.html { render :edit }

      end
    end
  end

  # DELETE /gangs/1
  # DELETE /gangs/1.json
  def destroy
    @gang.destroy
    respond_to do |format|
      format.html { redirect_to campaign_player_path( @campaign, @player ), notice: 'La bande a été correctement supprimée.' }

    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def gang_params
      params.permit(:icon )
    end
end
