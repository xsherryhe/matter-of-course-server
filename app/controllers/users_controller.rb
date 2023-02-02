class UsersController < ApplicationController
  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
    respond_with @user || false
  end
end
