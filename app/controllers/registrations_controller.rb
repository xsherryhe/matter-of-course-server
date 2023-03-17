class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  include DeviseRespondable

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      message = nil
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        message = :signed_up
      else
        expire_data_after_sign_in!
        message = :"signed_up_but_#{resource.inactive_message}"
      end
      respond_with_message(message)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with_errors
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      message = message_for_update(prev_unconfirmed_email)
      respond_with_message(message)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with_errors
    end
  end

  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield resource if block_given?
    head :ok
  end

  private

  def configure_sign_up_params
    devise_parameter_sanitizer.permit :sign_up,
                                      keys: [profile_attributes: %i[first_name middle_name last_name avatar]]
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit :account_update,
                                      keys: [profile_attributes: %i[id first_name middle_name last_name avatar]]
  end

  def message_for_update(prev_unconfirmed_email)
    if update_needs_confirmation?(resource, prev_unconfirmed_email)
      :update_needs_confirmation
    elsif sign_in_after_change_password?
      :updated
    else
      :updated_but_not_signed_in
    end
  end
end
