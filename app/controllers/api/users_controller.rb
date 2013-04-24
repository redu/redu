module Api
  class UsersController < ApiController
    def show
      @user = if params[:id]
        User.find(params[:id])
      else
        current_user
      end

      authorize! :read, @user
      respond_with @user
    end

    # /api/spaces/:space_id/users
    # /api/courses/:course_id/users
    # /api/environments/:environment_id/users
    def index
      context = context(params)
      authorize! :read, context

      users = users_with_indiferent_access(context)
      users = filter_by_role(context, users, params[:role]) if params[:role]

      if params[:reduce]
        respond_to do |format|
          format.json do
            render :json => users.map{ |user|
              { :id => user.id, :name =>user.display_name }}.to_json
          end
        end
      else
        users = users.includes(:social_networks, :tags)
        respond_with(:api, context, users)
      end
    end

    protected

    def context(params)
      if params.has_key?(:course_id)
        Course.find(params[:course_id])
      elsif params.has_key?(:environment_id)
        Environment.find(params[:environment_id])
      elsif params.has_key?(:user_id)
        User.find(params[:user_id])
      else
        Space.find(params[:space_id])
      end
    end

    def filter_by_role(context, users, role)
      case context
      when Space
        users.where(:user_space_associations => { :role => Role[role.to_sym] })
      when Environment
        users.where(:user_environment_associations => { :role => Role[role.to_sym] })
      when Course
        users.where(:course_enrollments => { :role => Role[role.to_sym] })
      else
        users
      end
    end

    def users_with_indiferent_access(context)
      # please Anything#users by convetion.
      context.respond_to?(:users) ? context.users : context.friends
    end
  end
end
