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

end
