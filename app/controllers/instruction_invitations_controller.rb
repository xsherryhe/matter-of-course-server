class InstructionInvitationsController < ApplicationController
  def index
    @invitations = current_user.received_instruction_invitations
                               .on_page(params[:page] || 1)
                               .includes(:course, :sender)
    respond_with @invitations, include: %i[course sender]
  end

  def update
    @invitation = InstructionInvitation.find(params[:id])
    return head :unauthorized unless current_user == @invitation.recipient

    @invitation.accepted! if params[:accept]
    head :ok
  end
end
