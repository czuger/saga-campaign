class UnitsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_unit, only: [:edit, :update, :destroy, :remains]
  before_action :set_gang, only: [:index, :new, :create]
  before_action :maintenance_cost_warning, only: [:index]

  # GET /units
  # GET /units.json
  def index
    @units = @gang.units.order( :id )
    @can_add_units = can_add_units
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

    @edition_disabled = false

    set_hash_for_vue(false )
  end

  # GET /units/1/edit
  def edit
    sub_edit
  end

  # POST /units
  # POST /units.json
  def create
    add_gang_to_unit

    @can_pay_unit = @unit.points <= @player.pp

    Unit.transaction do
      respond_to do |format|
        if @can_pay_unit && @unit.save

          after_unit_update( :create,
                             amount: @unit.amount, unit_libe: @unit.libe, gang_name: @gang.name )

          pay_unit( @unit.points )

          check_maintenance_status!

          format.html { redirect_to gang_units_path( @gang ), notice: t( '.success' ) }
        else
          set_units_rules_data
          flash[ :alert ] = @can_pay_unit ? '' : I18n.t( 'units.alert.cant_pay' )
          set_hash_for_vue( true )
          format.html { render :new }
        end
      end
    end

  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    # add_gang_to_unit

    unit_cost = unit_params[ :points ].to_f - @unit.points
    @can_pay_unit = unit_cost <= @player.pp

    Unit.transaction do
      respond_to do |format|

        if @can_pay_unit && @unit.update(unit_params)

          after_unit_update( :update,
            amount: @unit.amount, unit_libe: @unit.libe, gang_name: @gang.name )

          pay_unit( unit_cost )

          check_maintenance_status!

          format.html do
            if @maintenance_status_fixed
              redirect_to campaigns_path
            else
              redirect_to gang_units_path( @gang ), notice: t( '.success' ), alert: @alert_message
            end
          end
        else
          sub_edit
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
      after_unit_update( :destroy,
                         amount: @unit.amount,  unit_libe: @unit.libe, gang_name: @gang.name )


      pay_unit( - current_points )
      check_maintenance_status!
    end

    if @maintenance_status_fixed
      redirect_to campaigns_path
    else
      redirect_to gang_units_path( @gang ), notice: t( '.success' ), alert: @alert_message
    end
  end

  def remains
    @campaign = @unit.gang.player.campaign

    cu = current_user
    allowed_users_ids = @campaign.players.map{ |p| p.user_id }

    raise "#{cu.inspect} not allowed to modify unit #{@unit.inspect}" unless allowed_users_ids.include?( cu.id )

    @unit.remains = [ params[ :remains ].to_f, @unit.amount ].min
    @unit.save!
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def add_gang_to_unit
      @h_params = unit_params.to_h
      @h_params[ :gang_id ] = @gang.id
      @h_params[ :name ] = GameRules::UnitNameGenerator.generate_unique_unit_name(@campaign )

      @unit = Unit.new( @h_params )
    end

    def after_unit_update( log_action, log_params )

      log_params[ :unit_name ] = {
        code: 'unit_name.in_sentence', amount: @unit.amount, unit_libe: Unit.unit_name_code( @unit.libe, @unit.weapon ) }
      log_params.delete( :amount )
      log_params.delete( :unit_libe )

      @campaign.add_log( @player,:units, log_action, log_params )

      set_gang_points

      if @player.maintenance_required
        if @gang.points < 4
          @gang.retreat!
          @alert_message = t( 'log.gangs.retreating_after_update', location: @gang.location )
        end
      end
    end

    def set_gang_points
      points_total = @gang.units.sum( :points )
      @gang.points = points_total
      @gang.save!
    end

    def pay_unit( amount )

      # We are not being refunded when removing maintenance units
      unless @player.maintenance_required
        @player.pp -= amount
        @player.save!

        # No log if we pay nothing
        if amount > 0
          @campaign.add_log( @player,:pp, :decrease, count: amount )
        elsif amount < 0
          @campaign.add_log( @player,:pp, :increase, count: -amount )
        end
      else
        if amount > 0
          raise "We shouldn't be able to add new units when maintenance is required."
        end
      end
    end

    def set_units_rules_data
      faction_data = GameRules::Factions.new( @campaign )
      @factions_data = faction_data.data[@player.faction]

      @factions_vue = GameRules::FactionsVue.new( @campaign )

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

        # If we have fixed our troop count and all players did we switch to next step.
        unless @player.maintenance_required
          if @campaign.players.where( maintenance_required: true ).count == 0

            cp_manager = GameRules::ControlPoints.new( @campaign )
            cp_manager.loose_pp_for_mainteance!

            @campaign.players_bet_for_initiative!

            @maintenance_status_fixed = true
          end
        end

      end
    end

    def maintenance_cost_warning
      @maintenance_warning = true if GameRules::ControlPoints.anticipating_maintenance_costs?(@player )
    end

    def set_hash_for_vue( on_edit )
      @hash_for_vue_js = {}

      # All the units data. This contains all info on potentially selected units.
      @hash_for_vue_js[ :units_data ] = @units

      # Translated data for the libe select
      @hash_for_vue_js[ :libe_select_data ] = @factions_vue.libe_select_data( @player )
      # Translated data for the weapon select
      @hash_for_vue_js[ :weapons_select_data ] = @factions_vue.weapons_select_data( @player )

      # Data of the current unit item if available
      @hash_for_vue_js[ :selected_libe ] = @unit.libe
      @hash_for_vue_js[ :selected_weapon ] = @unit.weapon
      @hash_for_vue_js[ :current_amount ] = @unit.amount

      # The remaining player pp to ensure modification of units will not cost too much
      @hash_for_vue_js[ :player_pp ] = @player.pp

      # Flags representing differents states
      # If maintenance is required, then the player can't add more units
      @hash_for_vue_js[ :troop_maintenance ] = @player.maintenance_required
      # The can add unit flag is false when player can't buy the units
      @hash_for_vue_js[ :can_add_units ] = can_add_units

      # The behavior of the vue is different on edit mode than new mode
      @hash_for_vue_js[ :on_edit ] = on_edit
    end

    def can_add_units
      @gang.points < 10 && @player.pp > 0
    end

  def sub_edit
    set_units_rules_data
    @edition_disabled = @gang.finalized && !@campaign.first_hiring_and_movement_schedule?
    set_hash_for_vue( true )
  end
end
