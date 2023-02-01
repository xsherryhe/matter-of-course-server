class UsersController < ApplicationController
  def show
    @user = params[:id] ? User.find(params[:id]) : (current_user || false)
    respond_with @user
  end
end
