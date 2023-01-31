class UsersController < ApplicationController
  def show
    @user = params[:id] ? User.find(params[:id]) : (current_user || false)
    render json: @user
  end
end
