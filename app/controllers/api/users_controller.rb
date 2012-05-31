module Api
  class UsersController < ApiController
    def show
      @user = User.find(params[:id])
      authorize! :read, @user
      respond_with @user
    end

    # /api/spaces/:space_id/users
    # /api/courses/:course_id/users
    # /api/environments/:environment_id/users
    def index
      @entity = find_and_authorize_entity
      authorize! :read, @entity
      @users = filter_roles(@entity, params[:role])

      respond_with(:api, @entity, @users)
    end

    protected

    def find_and_authorize_entity
      if params.has_key?(:course_id)
        Course.find(params[:course_id])
      elsif params.has_key?(:environment_id)
        Environment.find(params[:environment_id])
      else
        Space.find(params[:space_id])
      end
    end

    def filter_roles(entity, role)
      if role
        if entity.is_a? Space
          entity.users.
            where(:user_space_associations => { :role => Role[role.to_sym] })
        elsif entity.is_a? Environment
          entity.users.
            where(:user_environment_associations => { :role => Role[role.to_sym] })
        else
          entity.users.
            where(:course_enrollments => { :role => Role[role.to_sym] })
        end
      else
        entity.users
      end
    end
  end
end
