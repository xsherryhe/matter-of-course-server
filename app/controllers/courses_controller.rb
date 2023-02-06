class CoursesController < ApplicationController
  before_action :authenticate_user!, only: %i[create update destroy]

  def index
    @courses = Course.on_page(params[:page] || 1)
    respond_with @courses
  end

  def show
    @course = Course.find(params[:id])

    unless @course.authorized_for?(current_user)
      return respond_with @course, only: :status, include: [host: { methods: :name }], status: :unauthorized
    end

    render json: @course.as_json_with_details(hosted: current_user == @course.host,
                                              authorized: current_user&.authorized_to_edit?(@course))
  end

  def create
    @course = current_user.hosted_courses.build(course_params)
    if @course.save
      render json: @course.as_json_with_details(hosted: true, authorized: true)
    else
      render json: @course.simplified_errors, status: :unprocessable_entity
    end
  end

  def update
    @course = Course.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@course)

    if @course.update(course_params.merge(editor: current_user))
      render json: @course.as_json_with_details(hosted: current_user == @course.host, authorized: true)
    else
      render json: @course.simplified_errors, status: :unprocessable_entity
    end
  end

  def destroy
    @course = Course.find(params[:id])
    return head :unauthorized unless current_user.authorized_to_edit?(@course)

    @course.destroy
    head :ok
  end

  private

  def course_params
    params.require(:course).permit(:title, :description, :instructor_logins)
  end
end
