class GangsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_gang, only: [:show, :edit, :update, :destroy, :change_location]
  before_action :set_player, only: [:create, :index, :new]

  def change_location
    Gang.transaction do
      @gang.location = params[:location]
      @gang.save!

      @campaign.players.each do |player|
        next if player.id == @player.id
        player.controls_points ||= []
        player.controls_points.delete( @gang.location )
        player.save!
      end

      @player.controls_points ||= []
      @player.controls_points << @gang.location
      @player.controls_points.uniq!
      @player.save!

      user_name = @player.user.name

      @campaign.logs.create!( data: "La bande #{@gang.number} de #{user_name} se déplace en #{@gang.location}." )
      @campaign.logs.create!( data: "#{user_name} prend le contrôle de #{@gang.location}." )
    end
  end

  # GET /gangs
  # GET /gangs.json
  def index
    @gangs = Gang.find_by_campaign_id_and_player_id( @campaign, @player )
    @localisations = GameRules::Map.new.localisations
  end

  # GET /gangs/new
  def new
    @gang = Gang.new
    @gang.faction = @player.faction
    @gang.number = @player.gangs.empty? ? 1 : @player.gangs.maximum( :number ) + 1
    @gang.name = GameRules::UnitNameGenerator.generate_unique_unit_name( @campaign )

    set_gang_additional_information
  end

  # GET /gangs/1/edit
  def edit
    set_gang_additional_information
  end

  # POST /gangs
  # POST /gangs.json
  def create
    @gang = Gang.new(gang_params)
    @gang.campaign = @campaign
    @gang.player = @player
    @gang.faction = @player.faction

    Gang.transaction do
      respond_to do |format|
        if @gang.save
          @campaign.logs.create!( data: "#{@player.user.name} a créé la bande n°#{@gang.number}." )

          format.html { redirect_to gang_units_path( @gang ), notice: 'La bande a bien été créée.' }

        else
          format.html {
            set_gang_additional_information
            render :new
          }

        end
      end
    end

  end

  # PATCH/PUT /gangs/1
  # PATCH/PUT /gangs/1.json
  def update
    respond_to do |format|
      if @gang.update(gang_params)
        format.html { redirect_to player_gangs_path( @player ), notice: 'Gang was successfully updated.' }

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
      format.html { redirect_to player_gangs_path( @player ), notice: 'La bande a été correctement supprimée.' }

    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def gang_params
      params.require( :gang ).permit( :icon, :number, :location, :name )
    end

    def set_gang_additional_information
      @icons = Dir["app/assets/images/gangs_icons/#{@player.faction}/*.svg"].map{ |e| e.gsub( 'app/assets/images/', '' ) }
      @select_localisations_options = GameRules::Factions.starting_positions( @player.faction )
    end
end
