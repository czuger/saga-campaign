class GangsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_gang, only: [:show, :edit, :update, :destroy, :change_location]
  before_action :set_player, only: [:create, :index, :new]

  # GET /gangs
  # GET /gangs.json
  def index
    @gangs = @player.gangs.where.not( gang_destroyed: true ).where.not( retreating: true ).order( 'id DESC' )
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
          @campaign.add_log( :gangs, :created, player_name: @player.user.name, gang_name: @gang.name )

          format.html { redirect_to gang_units_path( @gang ),
                                    notice: I18n.t( 'gangs.notice.created', name: @gang.name ) }

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
        format.html { redirect_to player_gangs_path( @player ),
                                  notice: I18n.t( 'gangs.notice.updated', name: @gang.name ) }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /gangs/1
  # DELETE /gangs/1.json
  def destroy
    Gang.transaction do
      gang_cost = @gang.points

      unless @player.maintenance_required
        @player.pp -= gang_cost
        @player.save!
      end

      @gang.destroy
      respond_to do |format|
        format.html { redirect_to player_gangs_path( @player ),
                                  notice: I18n.t( 'gangs.notice.destroyed', name: @gang.name ) }
        
        @campaign.add_log( :gangs, :destroyed, player_name: @player.user.name, gang_name: @gang.name )

        if gang_cost > 0
          @campaign.logs.create!( data: I18n.t( 'log.pp.increase', name: @player.user.name, count: gang_cost ) )
        end
      end

    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def gang_params
      params.require( :gang ).permit( :icon, :number, :location, :name )
    end

    def set_gang_additional_information
      @icons = @player.remaining_icons_list
      @select_localisations_options = GameRules::Factions.starting_positions( @campaign, @player )
    end
end
