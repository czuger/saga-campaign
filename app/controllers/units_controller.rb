class UnitsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  before_action :set_gang, only: [:index, :new, :create]

  # GET /units
  # GET /units.json
  def index
    @units = @gang.units.order( :id )
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
    @edition = true
  end

  # POST /units
  # POST /units.json
  def create
    add_gang_to_unit

    @can_pay_unit = @unit.points <= @player.pp

    Unit.transaction do
      respond_to do |format|
        if @can_pay_unit && @unit.save

          after_unit_update( t( '.log', user_name: @user.name, amount: @unit.amount, unit_libe: @unit.libe, gang_name: @gang.name ) )
          pay_unit( @unit.points )

          check_maintenance_status!

          format.html { redirect_to gang_units_path( @gang ), notice: t( '.success' ) }
        else
          set_units_rules_data
          flash[ :alert ] = @can_pay_unit ? '' : I18n.t( 'units.alert.cant_pay' )
          format.html { render :new }
        end
      end
    end

  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    # add_gang_to_unit

    @can_pay_unit = unit_params[ :points ].to_f <= @player.pp

    Unit.transaction do
      respond_to do |format|

        current_points = @unit.points

        if @can_pay_unit && @unit.update(unit_params)

          after_unit_update( t( '.log', user_name: @user.name, amount: @unit.amount,  unit_libe: @unit.libe, gang_name: @gang.name ) )
          pay_unit( @unit.points - current_points )

          check_maintenance_status!

          format.html { redirect_to gang_units_path( @gang ), notice: t( '.success' ) }
        else
          set_units_rules_data
          flash[ :alert ] = @can_pay_unit ? '' : I18n.t( 'units.alert.cant_pay' )
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    Unit.transaction do
      current_points = @unit.points

      @unit.destroy

      set_gang_points
      @campaign.logs.create!(
        data:
          after_unit_update( t( '.log', user_name: @user.name, amount: @unit.amount,  unit_libe: @unit.libe, gang_name: @gang.name ) )
      )

      pay_unit( - current_points )
      check_maintenance_status!
    end

    respond_to do |format|
      format.html { redirect_to gang_units_path( @gang ), notice: t( '.success' ) }

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
      @campaign.logs.create!( data: log_string )

      set_gang_points
    end

    def set_gang_points
      points_total = @gang.units.sum( :points )
      @gang.points = points_total
      @gang.save!
    end

    def pay_unit( amount )
      @player.pp -= amount
      @player.save!

      # No log if we pay nothing
      if amount > 0
        @campaign.logs.create!( data: I18n.t( 'log.pp.decrease', name: @player.user.name, count: amount ) )
      elsif amount < 0
        @campaign.logs.create!( data: I18n.t( 'log.pp.increase', name: @player.user.name, count: -amount ) )
      end

    end

    def set_units_rules_data
      faction_data = GameRules::Factions.new

      @unit_select_options_for_faction = faction_data.unit_select_options_for_faction( @gang.faction )
      # @weapon_select_options_for_faction_warlord = faction_data.weapon_select_options_for_faction_and_unit(
      #   @gang.faction, @unit.libe )

      # @weapon_select_options_prepared_strings = faction_data.weapon_select_options_prepared_strings( @gang.faction )

      @factions_data = GameRules::Factions.new.data[@player.faction]


      @units = GameRules::Unit.new.data
      @unit_data = @units[@unit.libe][@unit.weapon]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:libe, :amount, :points, :weapon)
    end

    def check_maintenance_status!
      # Only if maintenance is required. Maintenance cost is not paid when buying units.
      if @player.maintenance_required
        GameRules::ControlPoints.check_maintenance_cost_for_single_player! @player
      end
    end
end
