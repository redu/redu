require "redu_responder"

module Api
  class CoursesController < ApiController
    respond_to :js

    def index
      @environment = Environment.find_by_id(params[:environment_id])
      @courses = @environment.try(:courses) || []

      respond_with @courses
    end

    def show
      @course = Course.find(params[:id])

      respond_with @course
    end

    def create
      @environment = Environment.find_by_id(params[:environment_id])
      @course = Course.new(params[:course]) do |c|
        c.environment = @environment
        c.owner = current_user
      end
      @course.save

      respond_with @environment, @course
    end

    def update
      @course = Course.find(params[:id])
      @course.update_attributes(params[:course])

      respond_with @course
    end

    def destroy
      @course = Course.find(params[:id])
      @course.destroy

      respond_with @course
    end

    private

    def self.responder
      Class.new(super).send :include, Roar::Rails::Responder
    end
  end
end
