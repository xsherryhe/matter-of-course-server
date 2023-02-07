class EnrollmentsController < ApplicationController
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotUnique do
    @enrollment.errors.add(:student, 'is not unique')
    render json: @enrollment.simplified_errors, status: :unprocessable_entity
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
end
