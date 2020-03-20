class MapController < ApplicationController

  def show
    @campaign = Campaign.find(params[:campaign_id] )
    @gangs = @campaign.gangs
    @map = Rules::Map.new
  end

end
