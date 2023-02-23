class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = params[:page]&.to_i || 1
    @messages = current_user.public_send("#{params[:type]}_messages")
    render json: { messages: @messages.on_page(@page), last_page: @messages.last_page?(@page) }
  end

  def show
    @message = Message.find(params[:id])
    render json: @message.as_json_with_details
  end

  def create
    @message = current_user.sent_messages.build(create_message_params)
    if @message.save
      render json: @message
    else
      render json: @message.simplified_errors, status: :unprocessable_entity
    end
  end

  def update
    @message = Message.find(params[:id])
    return head :unauthorized unless @message.recipient == current_user

    if @message.update(update_message_params)
      render json: @message
    else
      render json: @message.simplified_errors, status: :unprocessable_entity
    end
  end

  private

  def create_message_params
    params.require(:message).permit(:subject, :body, :recipient_login, :parent_id)
  end

  def update_message_params
    params.require(:message).permit(:read_status)
  end
end
