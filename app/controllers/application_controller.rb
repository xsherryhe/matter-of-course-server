class ApplicationController < ActionController::Base
  respond_to :json
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :send_csrf_token

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: "This #{exception.model.constantize.model_name.human.downcase} no longer exists." },
           status: :unprocessable_entity
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: %i[username email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
    devise_parameter_sanitizer.permit :account_update, keys: %i[email password password_confirmation remember_me]
  end

  def send_csrf_token
    return unless /localhost|xsherryhe.github.io/ =~ request.origin

    headers['CSRF-TOKEN'] = form_authenticity_token
  end
end
