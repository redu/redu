module Api
  class SpacesController < Api::ApiController
    # GET /api/course/:course_id/spaces?user_id=1&role=member
    # GET /api/users/:user_id/spaces?course_id=1&role=member
    def index
      @context = context
      @spaces = @context.spaces

      if params[:role] && params[:user_id]
        role = Role[params[:role].to_sym]
        @spaces = @spaces.where(:user_space_associations => { :role => role })
      elsif params[:course_id] && params[:user_id] && params[:role]
        role = Role[params[:role].to_sym]
        @spaces = @spaces.includes(:user_space_associations).
          where(:user_space_associations => { :role => role, :user_id => params[:user_id], :course_id => params[:course_id] })
      end

      respond_with :api, @context, @spaces
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

    protected

    def context
      if c_id = params[:course_id]
        Course.find(c_id)
      else
        User.find(params[:user_id])
      end
    end
  end
end
