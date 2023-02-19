class UsersController < ApplicationController
  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
    return respond_with false unless @user

    respond_with @user, methods_from_params
  end
end

private

def methods_from_params
  methods = {}
  if params[:with]
    with = params[:with].to_sym
    methods[with] = @user.public_send(with, current_user, params[:page] || 1, scope_from_params)
  end
  methods
end

def scope_from_params
  return {} unless params[:scope]

  params[:scope].split(',').each_with_object({}) do |string, hash|
    key, value = string.split('_')
    hash[key.to_sym] = value.to_i
  end
end
