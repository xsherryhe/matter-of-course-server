class CoursesController < ApplicationController
  def index
    @courses = Course.on_page(params[:page] || 1)
    render json: @courses
  end
end
