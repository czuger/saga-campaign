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

    @unit.libe = :seigneur
    @unit.weapon = '-'
    @unit.amount = 1
    @unit.points = 0

    set_units_rules_data
  end

  # GET /units/1/edit
  def edit
    set_units_rules_data
  end

  # POST /units
  # POST /units.json
  def create
    add_gang_to_unit

    Unit.transaction do
      respond_to do |format|
        if @unit.save

          after_unit_update( "#{@user.name} a ajouté une unité de #{@unit.amount} #{@unit.libe} à la bande n°#{@gang.number}." )

          format.html { redirect_to gang_units_path( @gang ), notice: 'Unit was successfully created.' }

        else
          format.html { render :new }

        end
      end
    end

  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    # add_gang_to_unit

    respond_to do |format|
      if @unit.update(unit_params)

        after_unit_update( "#{@user.name} a modifie une unité en #{@unit.amount} #{@unit.libe} dans la bande n°#{@gang.number}." )

        format.html { redirect_to gang_units_path( @gang ), notice: 'Unit was successfully updated.' }

      else
        format.html { render :edit }

      end
    end
  end

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
      format.html { redirect_to gang_units_path( @gang ), notice: "L'unité a bien été supprimée." }

    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def add_gang_to_unit
      @h_params = unit_params.to_h
      @h_params[ :gang_id ] = @gang.id
      @h_params[ :name ] = GameRules::UnitNameGenerator.generate_unique_unit_name(@campaign )

      @unit = Unit.new( @h_params )
    end

    def after_unit_update( log_string )
      set_gang_points

      @campaign.logs.create!( data: log_string )
    end

    def set_gang_points
      points_total = @gang.units.sum( :points )
      @gang.update!( points: points_total )
    end

    def set_units_rules_data
      faction_data = GameRules::Factions.new

      @unit_select_options_for_faction = faction_data.unit_select_options_for_faction( @gang.faction )
      @weapon_select_options_for_faction_warlord = faction_data.weapon_select_options_for_faction_and_unit(
        @gang.faction, @unit.libe )

      @weapon_select_options_prepared_strings = faction_data.weapon_select_options_prepared_strings( @gang.faction )

      @units = GameRules::Unit.new.data
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:libe, :amount, :points, :weapon)
    end
end
