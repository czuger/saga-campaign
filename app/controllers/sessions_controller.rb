class SessionsController < ApplicationController

	def create
		@user = User.find_or_create_from_auth_hash(auth_hash)

		session['current_user_id'] = @user.id
		redirect_to users_show_path
  end

  def destroy
    session['current_user_id'] = nil
    redirect_to root_url
  end

  # Welcome screen
  def show
    redirect_to campaigns_path if current_user
  end

	protected

	def auth_hash
		request.env['omniauth.auth']
	end

end
