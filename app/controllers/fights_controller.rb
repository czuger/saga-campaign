class FightsController < ApplicationController

  before_action :require_logged_in!
  before_action :set_campaign

  def show
    @fight = FightResult.find( params[:id] )

    @game_rules_units = GameRules::Unit.new

    @result = @fight.fight_data[:result]
  end

  def index
    @fights = @campaign.fight_results.order( 'id DESC' )
  end

  def create
    attacker = Gang.find( params[:attacker] )

    gf = GameRules::Fight.new( @campaign.id, attacker.location,
                          params[:attacker], params[:defender] )
    gf.go

    redirect_to campaign_fights_path( @campaign )
  end

  def new
    @gangs = []

    @campaign.players.each do |player|
      user = player.user

      player.gangs.each do |gang|
        @gangs << [ "Bande n° #{gang.number} de #{user.name}", gang.id ]
      end
    end
  end
end
