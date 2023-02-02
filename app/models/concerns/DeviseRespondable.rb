module DeviseRespondable
  private

  def respond_with_message(message)
    data = [[resource_name, resource.as_json], [:message, find_message(message)]].to_h
    render json: data
  end

  def respond_with_errors
    render json: resource.simplified_errors, status: :unprocessable_entity
  end
end
