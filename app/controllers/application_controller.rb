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

    @player = Player.find_by_campaign_id_and_user_id( @campaign, current_user )
    raise "Player (player_id: #{current_user.id} not found for campaign_id: #{@campaign.id}" unless @player

    raise "User mismatch : current_user.id != @players.user.id (#{current_user.id} != #{@player.user.id})" unless current_user.id == @player.user.id
  end

  # Mean set gang for modification. For read only, use find directly
  def set_gang
    @gang = Gang.find( params[:gang_id] || params[:id] )

    raise "Gang (gang_id: #{params[:gang_id] || params[:id]} not found" unless @gang

    @campaign = @gang.campaign
    @player = @gang.player
    @user = @player.user

    unless @user_id == current_user.id
      "#{current_user} is not allowed to modify #{@gang}"
    end
  end

  def set_unit
    @unit = Unit.find( params[:unit_id] || params[:id] )

    raise "Unit (unit_id: #{params[:unit_id] || params[:id]} not found" unless @unit

    @gang = @unit.gang
    @campaign = @gang.campaign
    @player = @gang.player
    @user = @player.user

    unless @user.id == current_user.id
      "#{current_user} is not allowed to modify #{@unit}"
    end
  end

end
