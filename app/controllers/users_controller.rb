class UsersController < ApplicationController
  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
    respond_with @user ? @user.with_name : false
  end
end
