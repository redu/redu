# -*- encoding : utf-8 -*-
class ChatMessageObserver < ActiveRecord::Observer
  def after_create(chat_message)
    Chat.find_or_create_and_append(chat_message)
  end
end
