class PasswordsController < Devise::PasswordsController
  include DeviseRespondable

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      head :ok
    else
      respond_with_errors
    end
  end
end
