class AssignmentSubmissionsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotUnique do
    @submission.errors.add(:student, 'is not unique')
    render json: @submission.simplified_errors, status: :unprocessable_entity
  end

  def index
    @parent = parent_from_params
    return head :unauthorized unless current_user.authorized_to_edit?(@parent)

    @page = params[:page]&.to_i || 1
    @submissions = @parent.assignment_submissions.complete.by_student(params[:student_id])

    render json: { submissions: @submissions.on_page(@page), last_page: @submissions.last_page?(@page) }
  end

  def show
    if params[:assignment_id]
      @assignment = assignment_from_params
      return head :unauthorized unless current_user.authorized_to_view?(@assignment)
    end

    @submission = submission_from_params
    return render json: false unless @submission
    return head :unauthorized unless current_user.authorized_to_view?(@submission)

    render json: @submission.as_json_with_details(user: current_user)
  end

  def create
    @assignment = assignment_from_params
    return head :unauthorized unless current_user.authorized_to_view?(@assignment)

    @submission = current_user.assignment_submissions.build(assignment_submission_params.merge(assignment: @assignment))
    if @submission.save
      render json: @submission.as_json_with_details(user: current_user)
    else
      render json: @submission.simplified_errors, status: :unprocessable_entity
    end
  end

  def update
    @assignment = assignment_from_params
    @submission = @assignment.assignment_submissions.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@submission)

    if @submission.update(assignment_submission_params)
      render json: @submission.as_json_with_details(user: current_user)
    else
      render json: @submission.simplified_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @submission = AssignmentSubmission.find(params[:id])
    return head :unauthorized unless current_user.owned?(@submission)

    @submission.destroy
    head :ok
  end

  private

  def assignment_submission_params
    params.require(:assignment_submission).permit(:completion_status, :body)
  end

  def parent_from_params
    parent_param = %i[course_id assignment_id].find { |param| params.key?(param) }
    parent_model = { course_id: Course, assignment_id: Assignment }[parent_param]
    parent_model.find(params[parent_param])
  end

  def assignment_from_params
    Assignment.find(params[:assignment_id])
  end

  def submission_from_params
    if params[:assignment_id]
      current_user.assignment_submissions.find_by(assignment: @assignment)
    else
      AssignmentSubmission.find(params[:id])
    end
  end
end
