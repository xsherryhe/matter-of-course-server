class AssignmentSubmissionsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotUnique do
    @submission.errors.add(:student, 'is not unique')
    render json: @submission.simplified_errors, status: :unprocessable_entity
  end

  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
    @assignment = Assignment.find(params[:assignment_id])
    @submission = @user.assignment_submissions.find_by(assignment: @assignment)
    respond_with @submission || false
  end

  def create
    @assignment = Assignment.find(params[:assignment_id])
    @submission = current_user.assignment_submissions.build(assignment_submission_params.merge(assignment: @assignment))

    if @submission.save
      render json: @submission
    else
      render json: @submission.simplified_errors, status: :unprocessable_entity
    end
  end

  private

  def assignment_submission_params
    params.require(:assignment_submission).permit(:completion_status, :body)
  end
end
