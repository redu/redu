module Api
  class SpacesController < Api::ApiController
    def index
      @course = Course.find(params[:course_id])
      @spaces = @course.try(:spaces) || []

      respond_with :api, @course, @spaces
    end

    def show
      @space = Space.find(params[:id])

      respond_with @space
    end

    def create
      @course = Course.find(params[:course_id])
      @space = Space.new(params[:space]) do |c|
        c.course = @course
        c.owner = current_user
      end
      @space.save

      respond_with @space
    end

    def update
      @space = Space.find(params[:id])
      @space.update_attributes(params[:space])

      respond_with @space
    end

    def destroy
      @space = Space.find(params[:id])
      @space.destroy

      respond_with @space
    end
  end
end
