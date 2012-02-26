module Api
  class CoursesController < ApiController
    respond_to :js

    def index
      @environment = Environment.find_by_id(params[:environment_id])
      @courses = @environment.try(:courses) || []

      respond_with :api, @environment, @courses
    end

    def show
      @course = Course.find(params[:id])

      respond_with :api, @course
    end

    def create
      @environment = Environment.find_by_id(params[:environment_id])
      @course = Course.new(params[:course]) do |c|
        c.environment = @environment
        c.owner = current_user
      end
      @course.save

      respond_with :api, @course
    end

    def update
      @course = Course.find(params[:id])
      @course.update_attributes(params[:course])

      respond_with @course
    end

    def destroy
      @course = Course.find(params[:id])
      @course.destroy

      respond_with :api, @course
    end
  end
end
