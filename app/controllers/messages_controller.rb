class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = current_user.public_send("#{params[:type]}_messages").on_page(params[:page] || 1)
    respond_with @messages
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    if @message.save
      render json: @message
    else
      render json: @message.simplified_errors, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:subject, :body, :recipient_login)
  end
end
