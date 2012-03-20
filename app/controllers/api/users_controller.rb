module Api
  class UsersController < ApiController
    def show
      @user = User.find(params[:id])
      respond_with @user
    end

    def index
      @entity = find_entity

      @users = @entity.users
      if role = params[:role]
        if @entity.class == Space
          @users = @users.
            where(:user_space_associations => { :role => Role[role.to_sym] })
        elsif @entity.class == Environment
          @users = @users.
            where(:user_environment_associations => { :role => Role[role.to_sym] })
        else
          @users = @users.
            where(:course_enrollments => { :role => Role[role.to_sym] })
        end
      end

      respond_with(:api, @entity, @users)
    end

    protected

    def find_entity
      if params.has_key?(:course_id)
        Course.find(params[:course_id])
      elsif params.has_key?(:environment_id)
        Environment.find(params[:environment_id])
      else
        Space.find(params[:space_id])
      end
    end
  end
end
