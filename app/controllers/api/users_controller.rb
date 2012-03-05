module Api
  class UsersController < ApiController
    def show
      @user = User.find(params[:id])
      respond_with @user
    end

    def index
      @space = Space.find(params[:space_id])

      @users = @space.users
      if role = params[:role]
        @users = @users.
          where(:user_space_associations => { :role => Role[role.to_sym] })
      end

      respond_with(:api, @space, @users)
    end
  end
end
