class UnitsController < ApplicationController
  before_action :require_logged_in!
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  before_action :set_gang, only: [:index, :new, :create]

  # GET /units
  # GET /units.json
  def index
    @units = Unit.all
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units
  # POST /units.json
  def create

    params = unit_params.to_h
    params[ :gang_id ] = @gang.id

    @unit = Unit.new( params )

    Unit.transaction do
      respond_to do |format|
        if @unit.save

          unless @player.user.unit_old_libe_strings.exists?( libe: params['libe'] )
            @player.user.unit_old_libe_strings.create!( libe: params['libe'] )
          end

          points_total = @gang.units.sum( :points )
          @gang.update!( points: points_total )

          @campaign.logs.create!( data:
            "#{@player.user.name} a ajouté une unité de #{@unit.amount} #{@unit.libe} à la bande n°#{@gang.number}."
          )

          format.html { redirect_to campaign_gang_units_path( @campaign, @gang ), notice: 'Unit was successfully created.' }
          format.json { render :show, status: :created, location: @unit }
        else
          format.html { render :new }
          format.json { render json: @unit.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @unit.update(unit_params)
        format.html { redirect_to @unit, notice: 'Unit was successfully updated.' }
        format.json { render :show, status: :ok, location: @unit }
      else
        format.html { render :edit }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy
    respond_to do |format|
      format.html { redirect_to units_url, notice: 'Unit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:libe, :amount, :points)
    end
end
