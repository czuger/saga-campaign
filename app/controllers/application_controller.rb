class ApplicationController < ActionController::Base

  def current_player
    begin
      @current_player ||= ( (s=session['current_user_id']) && User.find( s ) )
    rescue
      @current_player = session['current_user_id'] = nil
    end
  end

end
