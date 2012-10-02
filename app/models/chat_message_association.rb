class ChatMessageAssociation < ActiveRecord::Base
  belongs_to :chat
  belongs_to :chat_message
end
