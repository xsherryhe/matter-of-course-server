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

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if resource_class.sign_in_after_reset_password
        message = resource.active_for_authentication? ? :updated : :updated_not_active
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        message = :updated_not_active
      end
      respond_with_message(message)
    else
      set_minimum_password_length
      respond_with_errors
    end
  end
end
