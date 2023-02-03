class UsersController < ApplicationController
  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
    return respond_with false unless @user

    methods = {}
    if params[:with]
      with = params[:with].to_sym
      methods[with] = @user.public_send(with, current_user)
    end
    respond_with @user, methods
  end
end
