class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  def show
    @assignment = Assignment.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_view?(@assignment)

    respond_with @assignment, include: params[:with] ? [params[:with]] : []
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@assignment)

    @assignment.destroy
    head :ok
  end
end
