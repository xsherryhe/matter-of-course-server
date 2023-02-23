class InstructionInvitationsController < ApplicationController
  def index
    @page = params[:page]&.to_i || 1
    @invitations = current_user.received_instruction_invitations
    render json: { invitations: @invitations.on_page(@page), last_page: @invitations.last_page?(@page) }
  end

  def batch_update
    @page = params[:page]&.to_i || 1
    @invitations = current_user.received_instruction_invitations.on_page(@page)

    @invitations.each { |invitation| invitation.pending! if invitation.unread? } if params[:read]
    head :ok
  end

  def update
    @invitation = InstructionInvitation.find(params[:id])
    return head :unauthorized unless current_user == @invitation.recipient

    @invitation.accepted! if params[:accept]
    head :ok
  end

  def destroy
    @invitation = InstructionInvitation.find(params[:id])
    return head :unauthorized unless current_user == @invitation.recipient

    @invitation.destroy
    head :ok
  end
end
