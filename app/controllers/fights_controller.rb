class FightsController < ApplicationController

  before_action :require_logged_in!
  before_action :set_campaign

  def show
    @fight = FightResult.find( params[:id] )

    @game_rules_units = GameRules::Unit.new

    @fight_data = @fight.fight_data
    @result = @fight.fight_data[:result]
    @casualties = @fight.fight_data.casualties
  end

  def index
    @fights = @campaign.fight_results.order( 'id DESC' )
  end

end
