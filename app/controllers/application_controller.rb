class ApplicationController < ActionController::Base

  def current_user
    begin
      @current_user ||= ( (s=session['current_user_id']) && User.find( s ) )
    rescue
      @current_user = session['current_user_id'] = nil
    end
  end

  def require_logged_in!
    redirect_to root_path unless current_user
  end

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id] || params[:id] )
    raise "Campaign not found for campaign_id: #{params[:campaign_id] || params[:id]}" unless @campaign
  end

  def set_player
    set_campaign

    if params[:player_id] || params[:id]
      @player = @campaign.players.find(params[:player_id] || params[:id] )
      raise "Player (player_id: #{params[:player_id] || params[:id]} not found for campaign_id: #{@campaign.id}" unless @player
    else
      # If we does not find the player from the parameters, then we will try to find him from the current campaign and the current player
      @player = Player.find_by_campaign_id_and_user_id( @campaign, current_user )
      raise "Player (player_id: #{current_user.id} not found for campaign_id: #{@campaign.id}" unless @player
    end

    raise "User mismatch : current_user.id != @players.user.id (#{current_user.id} != #{@player.user.id})" unless current_user.id == @player.user.id
  end

  def set_gang
    set_player
    @gang = @player.gangs.find( params[:gang_id] || params[:id] )
    raise "Gang (gang_id: #{params[:gang_id] || params[:id]} not found for player_id: #{@player.id}" unless @gang
  end

  def set_unit
    set_gang
    @unit = @gang.units.find( params[ :id ] )
    raise "Unit (unit_id: #{params[:unit_id] || params[:id]} not found for gang_id: #{@gang.id}" unless @unit
  end

end
