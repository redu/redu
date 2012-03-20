module Api
  class CoursesController < ApiController
    respond_to :js

    def index
      @environment = Environment.find(params[:environment_id])
      @courses = @environment.try(:courses) || []

      respond_with :api, @environment, @courses
    end

    def show
      @course = Course.find(params[:id])

      respond_with :api, @course
    end

    def create
      @environment = Environment.find(params[:environment_id])
      @course = Course.new(params[:course]) do |c|
        c.environment = @environment
        c.owner = current_user
      end
      @course.save
      @plan = Plan.from_preset(params[:course][:plan].try(:to_sym))
      @plan.user = current_user
      @course.plans << @plan
      @plan.save
      @course.create_quota
      @plan.create_invoice_and_setup

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
