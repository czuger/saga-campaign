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
    @player = Player.find( params[:player_id] || params[:id] )

    raise "Player (player_id: #{params[:player_id] || params[:id]} not found" unless @player
    raise "User mismatch : current_user.id != @players.user_id (#{current_user.id} != #{@player.user_id})" unless current_user.id == @player.user_id

    @campaign = @player.campaign
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
