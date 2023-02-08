class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotUnique do
    @enrollment.errors.add(:student, 'is not unique')
    render json: @enrollment.simplified_errors, status: :unprocessable_entity
  end

  def index
    @course = Course.find(params[:course_id])
    return head :unauthorized unless current_user.authorized_to_edit?(@course)

    respond_with @course.enrollments.roster
  end

  def create
    @course = Course.find(params[:course_id])
    @enrollment = @course.enrollments.build(student: current_user)

    if @enrollment.save
      head :ok
    else
      render json: @enrollment.simplified_errors, status: :unprocessable_entity
    end
  end

  def destroy
    return head :unauthorized unless current_user.id == params[:id].to_i

    @course = Course.find(params[:course_id])
    @enrollment = @course.enrollments.find_by(student_id: params[:id])

    @enrollment.destroy
    head :ok
  end
end
