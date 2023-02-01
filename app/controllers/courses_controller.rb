class CoursesController < ApplicationController
  def index
    @courses = Course.on_page(params[:page] || 1)
    respond_with @courses
  end
end
