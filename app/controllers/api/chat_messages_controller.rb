module Api
  class ChatMessagesController < Api::ApiController
    def show
      @chat_message = ChatMessage.find(params[:id])
      authorize! :read, @chat_message
      respond_with @chat_message
    end

    def index
      @chat = Chat.find(params[:chat_id])
      authorize! :read, @chat
      @chat_messages = @chat.chat_messages

      respond_with @chat_messages
    end
  end
end
