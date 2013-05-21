# -*- encoding : utf-8 -*-
module Api
  class SpacesController < Api::ApiController
    # GET /api/users/:user_id/spaces?course=1&role=member
    def index
      @context = context # course ou user
      authorize! :read, @context
      @spaces = @context.spaces

      if params[:user_id]
        if params[:role]
          role = Role[params[:role].to_sym]
          @spaces = @spaces.where(:user_space_associations => { :role => role })
        end
        if course_id = params[:course]
          @spaces = @spaces.where(:course_id => course_id)
        end
      end

      respond_with :api, @spaces
    end

    def show
      @space = Space.find(params[:id])
      authorize! :read, @space

      respond_with @space
    end

    def create
      @course = Course.find(params[:course_id])
      @space = Space.new(params[:space]) do |c|
        c.course = @course
        c.owner = current_user
      end
      authorize! :create, @space
      @space.save

      respond_with @space
    end

    def update
      @space = Space.find(params[:id])
      authorize! :manage, @space
      @space.update_attributes(params[:space])

      respond_with @space
    end

    def destroy
      @space = Space.find(params[:id])
      authorize! :manage, @space
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
