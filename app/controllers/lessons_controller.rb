class LessonsController < ApplicationController
  before_action :authenticate_user!

  def create
    @course = Course.find(params[:course_id])
    return head :unauthorized unless current_user.authorized_to_edit?(@course)

    @lesson = @course.lessons.build(lesson_params)
    if @lesson.save
      render json: @lesson.as_json_with_details(authorized: true)
    else
      render json: @lesson.simplified_errors, status: :unprocessable_entity
    end
  end

  def show
    @lesson = Lesson.find(params[:id])
    return head :unauthorized unless @lesson.authorized_to_view?(current_user)

    render json: @lesson.as_json_with_details(authorized: current_user.authorized_to_edit?(@lesson))
  end

  def update
    @lesson = Lesson.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@lesson)

    if @lesson.update(lesson_params)
      render json: @lesson.as_json_with_details(authorized: true)
    else
      render json: @lesson.simplified_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson = Lesson.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@lesson)

    @lesson.destroy
    head :ok
  end

  private

  def lesson_params
    params.require(:lesson)
          .permit(:title, :order,
                  lesson_sections_attributes: %i[id temp_id title body order _destroy],
                  assignments_attributes: %i[id temp_id title body order _destroy])
  end
end
