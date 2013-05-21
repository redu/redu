# -*- encoding : utf-8 -*-
class Chat < ActiveRecord::Base
  # Representa um chat entre 2 usuários. É comumente criado no ChatMessageObserver
  # quando a primeira conversa entre dois usuários acontece.
  #
  # user = User.find(4)
  # contact = User.find(5)
  # message =  ChatMessage.create(:user => user, :contact => contact,
  #                               :message => "hello")
  # message.user
  # => #<User id: 4>
  #  message.contact
  # => #<User id: 5>
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'
  has_many :chat_message_associations
  has_many :chat_messages, :through => :chat_message_associations,
    :dependent => :destroy

  validates_uniqueness_of :user_id, :scope => [:contact_id]

  # Cria chats para a mensagem passada como parâmetro, caso não exista um.
  #
  # message =  ChatMessage.create(:user => user, :contact => contact,
  #                               :message => "hello")
  # chat1, chat2 = Chat.create_for(message)
  def self.create_for(chat_message)
    uid, cid = chat_message.user_id, chat_message.contact_id

    c1 = Chat.find(:first, :conditions => {:user_id => uid, :contact_id => cid})
    c1 ||= create do |chat|
      chat.user_id = uid
      chat.contact_id = cid
    end

    c2 = Chat.find(:first, :conditions => {:user_id => cid, :contact_id => uid})
    c2 ||= create do |chat|
      chat.user_id = cid
      chat.contact_id = uid
    end

    [c1, c2]
  end

  def self.find_or_create_and_append(chat_message)
    c1, c2 = create_for(chat_message)
    c1.chat_messages << chat_message
    c2.chat_messages << chat_message

    [c1, c2]
  end
end
