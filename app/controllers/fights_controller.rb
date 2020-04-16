class FightsController < ApplicationController

  before_action :require_logged_in!
  before_action :set_campaign

  def show
    @fight = FightResult.find( params[:id] )

    @game_rules_units = GameRules::Unit.new

    @result = @fight.fight_data[:result]
    @casualties = @fight.fight_data.casualties
  end

  def index
    @fights = @campaign.fight_results.order( 'id DESC' )
  end

  def create
    attacker = Gang.find( params[:attacker] )

    gf = Fight::Base.new(@campaign.id, attacker.location,
                         params[:attacker], params[:defender] )
    gf.go

    redirect_to campaign_fights_path( @campaign )
  end

  def new
    common_locations = {}
    @campaign.gangs.pluck( :location, :id ).each do |e|
      common_locations[e.first] ||= []
      common_locations[e.first] << e.last
    end

    @fights = []
    common_locations.each_pair do |k, v|
      if v.count > 1

        @fights << OpenStruct.new(
          location: k,
          attacker: Gang.find( v[0] ),
          defender: Gang.find( v[1] )
        )

      end
    end

  end
end
