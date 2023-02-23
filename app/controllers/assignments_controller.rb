class AssignmentsController < ApplicationController
  before_action :authenticate_user!
  def index
    @course = Course.find(params[:course_id])
    return head :unauthorized unless current_user.authorized_to_view_details?(@course)

    @page = params[:page]&.to_i || 1
    @assignments = @course.assignments
    render json: { assignments: @assignments.on_page(@page),
                   last_page: @assignments.last_page?(@page) }
  end

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
