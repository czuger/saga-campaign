class FightsController < ApplicationController

  before_action :require_logged_in!
  before_action :set_campaign

  def index
    @fights = @campaign.fight_results
  end

  def new
  end
end
