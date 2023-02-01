class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

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
end

private

def respond_with_message(message)
  data = [[resource_name, (resource.with_name || resource.as_json)], [:message, find_message(message)]].to_h
  render json: data
end

def respond_with_errors
  errors = resource.errors.each_with_object({}) do |error, hash|
    (hash[error.attribute] ||= []) << error.message
  end
  render json: errors, status: :unprocessable_entity
end

def configure_sign_up_params
  devise_parameter_sanitizer.permit :sign_up,
                                    keys: [profile_attributes: %i[first_name middle_name last_name]]
end

def configure_account_update_params
  devise_parameter_sanitizer.permit :account_update,
                                    keys: [profile_attributes: %i[id first_name middle_name last_name]]
end
