class SessionsController < Devise::SessionsController
  include DeviseRespondable

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with_message(:signed_in)
  end
end
