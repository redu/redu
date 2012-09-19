module Api
  class ChatsController < Api::ApiController
    def show
      @chat = Chat.find(params[:id])
      authorize! :read, @chat
      respond_with @chat
    end

    def index
      @user = User.find(params[:user_id])
      authorize! :manage, @user

      @chats = @user.chats
      respond_with @chats
    end
  end
end
