module Api
  class ChatsController < Api::ApiController
    def show
      @chat = Chat.find(params[:id])
      authorize! :read, @chat
      respond_with @chat
    end
  end
end
