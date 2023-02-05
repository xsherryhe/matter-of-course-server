class InstructorsController < ApplicationController
  def destroy
    @course = Course.find(params[:course_id])
    @instructor = User.find(params[:id])
    return head :unauthorized unless [@course.host, @instructor].include?(current_user)

    if @course.single_instructor?
      return render json: { error: 'Courses must have at least one instructor.' }, status: :unprocessable_entity
    end

    @course.instructors.delete(@instructor)
    head :ok
  end
end
