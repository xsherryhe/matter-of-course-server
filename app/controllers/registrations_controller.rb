class RegistrationsController < Devise::RegistrationsController
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
  data = [[resource_name, resource.as_json], [:message, find_message(message)]].to_h
  render json: data
end

def respond_with_errors
  errors = resource.errors.each_with_object({}) do |error, hash|
    (hash[error.attribute] ||= []) << error.full_message
  end
  render json: errors, status: :unprocessable_entity
end
