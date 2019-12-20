class GangsController < ApplicationController
  before_action :set_gang, only: [:show, :edit, :update, :destroy]

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
  end

  # GET /gangs/1/edit
  def edit
  end

  # POST /gangs
  # POST /gangs.json
  def create
    @gang = Gang.new(gang_params)

    respond_to do |format|
      if @gang.save
        format.html { redirect_to @gang, notice: 'Gang was successfully created.' }
        format.json { render :show, status: :created, location: @gang }
      else
        format.html { render :new }
        format.json { render json: @gang.errors, status: :unprocessable_entity }
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
      format.html { redirect_to gangs_url, notice: 'Gang was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gang
      @gang = Gang.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gang_params
      params.require(:gang).permit(:campaign_id, :player_id, :icon)
    end
end
