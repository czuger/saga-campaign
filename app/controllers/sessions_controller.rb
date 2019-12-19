class SessionsController < ApplicationController

	def create
		@user = User.find_or_create_from_auth_hash(auth_hash)

		# pp @user

		session['current_user_id'] = @user.id
		redirect_to boards_path
	end

	protected

	def auth_hash
		request.env['omniauth.auth']
	end

end
