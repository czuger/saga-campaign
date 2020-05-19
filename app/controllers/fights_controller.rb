class FightsController < ApplicationController

  before_action :require_logged_in!
  before_action :set_campaign, except: [ :report_edit, :report_save ]
  before_action :set_movement_result, only: [ :report_edit, :report_save ]

  def report_edit
  end

  def report_save

  end

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

  def set_movement_result
    @movement_result = MovementsResult.find( params[ :movement_result_id ] )
    @campaign = @movement_result.campaign
    @attacking_units = @movement_result.gang.units.order( :id )
    @defending_units = @movement_result.intercepted_gang.units.order( :id )

    cu = current_user
    allowed_users_ids = @campaign.players.map{ |p| p.user_id }

    raise "#{cu.inspect} not allowed to modify movement_result #{@movement_result.inspect}" unless allowed_users_ids.include?( cu.id )
  end

end
