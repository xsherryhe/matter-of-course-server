class CoursesController < ApplicationController
  before_action :authenticate_user!, only: %i[create]

  def index
    @courses = Course.on_page(params[:page] || 1)
    respond_with @courses
  end

  def create
    @course = current_user.created_courses.build(course_params)
    if @course.save
      respond_with @course
    else
      render json: @course.simplified_errors, status: :unprocessable_entity
    end
  end

  def show
    @course = Course.find(params[:id])

    unless current_user.authorized_for?(@course)
      return respond_with @course, only: :status, include: [creator: { methods: :name }], status: :unauthorized
    end

    respond_with @course,
                 include: [{ creator: { methods: :name } }, { instructors: { methods: :name } }, :lessons],
                 authorized: current_user.authorized_to_edit?(@course)
  end

  private

  def course_params
    params.require(:course).permit(:title, :description, :instructor_logins)
  end
end
