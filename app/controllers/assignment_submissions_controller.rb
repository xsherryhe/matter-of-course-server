class AssignmentSubmissionsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotUnique do
    @submission.errors.add(:student, 'is not unique')
    render json: @submission.simplified_errors, status: :unprocessable_entity
  end

  def index
    @parent = indexing_parent
    return head :unauthorized unless current_user.authorized_to_edit?(@parent)

    @submissions = @parent.assignment_submissions.complete.by_student(params[:student_id]).on_page(params[:page] || 1)
    respond_with @submissions
  end

  def show
    @submission = submission_from_params
    return render json: false unless @submission
    return head :unauthorized unless current_user.authorized_to_view?(@submission)

    render json: @submission.as_json_with_details(authorized: current_user.authorized_to_edit?(@submission))
  end

  def create
    @assignment = Assignment.find(params[:assignment_id])
    @submission = current_user.assignment_submissions.build(assignment_submission_params.merge(assignment: @assignment))

    if @submission.save
      render json: @submission.as_json_with_details(authorized: true)
    else
      render json: @submission.simplified_errors, status: :unprocessable_entity
    end
  end

  def update
    @assignment = Assignment.find(params[:assignment_id])
    @submission = @assignment.assignment_submissions.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@submission)

    if @submission.update(assignment_submission_params)
      render json: @submission.as_json_with_details(authorized: true)
    else
      render json: @submission.simplified_errors, status: :unprocessable_entity
    end
  end

  private

  def indexing_parent
    parent_param = %i[course_id assignment_id].find { |param| params.key?(param) }
    parent_model = { course_id: Course, assignment_id: Assignment }[parent_param]
    parent_model.find(params[parent_param])
  end

  def assignment_submission_params
    params.require(:assignment_submission).permit(:completion_status, :body)
  end

  def submission_from_params
    if params[:assignment_id]
      current_user.assignment_submissions.find_by(assignment_id: params[:assignment_id])
    else
      AssignmentSubmission.find(params[:id])
    end
  end
end
