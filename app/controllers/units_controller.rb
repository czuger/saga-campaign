class UnitsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  before_action :set_gang, only: [:index, :new, :create]

  # GET /units
  # GET /units.json
  def index
    @units = @gang.units
  end

  # GET /units/1
  # GET /units/1.json
  # def show
  # end

  # GET /units/new
  def new
    @unit = Unit.new

    faction_data = Rules::Factions.new

    @unit_select_options_for_faction = faction_data.unit_select_options_for_faction( @gang.faction )
    @weapon_select_options_prepared_strings = faction_data.weapon_select_options_prepared_strings( @gang.faction )
  end

  # GET /units/1/edit
  # def edit
  # end

  # POST /units
  # POST /units.json
  def create
    add_gang_to_unit

    Unit.transaction do
      respond_to do |format|
        if @unit.save

          after_unit_update( "#{@player.user.name} a ajouté une unité de #{@unit.amount} #{@unit.libe} à la bande n°#{@gang.number}." )

          format.html { redirect_to campaign_gang_units_path( @campaign, @gang ), notice: 'Unit was successfully created.' }

        else
          format.html { render :new }

        end
      end
    end

  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  # def update
  #   add_gang_to_unit
  #
  #   respond_to do |format|
  #     if @unit.update(unit_params)
  #
  #       after_unit_update( "#{@player.user.name} a modifie une unité en #{@unit.amount} #{@unit.libe} dans la bande n°#{@gang.number}." )
  #
  #       format.html { redirect_to @unit, notice: 'Unit was successfully updated.' }
  #
  #     else
  #       format.html { render :edit }
  #
  #     end
  #   end
  # end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    Unit.transaction do
      @unit.destroy

      set_gang_points

      @campaign.logs.create!(
        data:
          "#{@player.user.name} a supprimé une unité de #{@unit.amount} #{@unit.libe} à la bande n°#{@gang.number}."
      )
    end

    respond_to do |format|
      format.html { redirect_to campaign_gang_units_path( @campaign, @gang ), notice: "L'unité a bien été supprimée." }

    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def add_gang_to_unit
      @h_params = unit_params.to_h
      @h_params[ :gang_id ] = @gang.id

      @unit = Unit.new( @h_params )
    end

    def after_unit_update( log_string )
      unless @player.user.unit_old_libe_strings.exists?( libe: @h_params['libe'] )
        @player.user.unit_old_libe_strings.create!( libe: @h_params['libe'] )
      end

      set_gang_points

      @campaign.logs.create!( data: log_string )
    end

    def set_gang_points
      points_total = @gang.units.sum( :points )
      @gang.update!( points: points_total )
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:libe, :amount, :points)
    end
end
