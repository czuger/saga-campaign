class UsersController < ApplicationController

  before_action :require_logged_in!

  def show
    current_user
  end
end
