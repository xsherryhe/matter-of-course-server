class EnrollmentsController < ApplicationController
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
