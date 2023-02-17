class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotUnique do
    @enrollment.errors.add(:student, 'is not unique')
    render json: @enrollment.simplified_errors, status: :unprocessable_entity
  end

  def index
    @course = Course.find(params[:course_id])
    return head :unauthorized unless current_user.authorized_to_edit?(@course)

    respond_with @course.enrollments.on_page(params[:page] || 1).roster
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
    @course = Course.find(params[:course_id])
    @enrollment = @course.enrollments.find_by!(student_id: params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@enrollment)

    @enrollment.destroy
    head :ok
  end
end
