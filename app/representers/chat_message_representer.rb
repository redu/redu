module ChatMessageRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :created_at
  property :updated_at
  property :message

  link :self do
    api_chat_message_url(self)
  end

  link :user do
    api_user_url(self.user)
  end

  link :contact do
    api_user_url(self.contact)
  end

  link :sender_chat do
    sender = self.chats.
      find(:first, :conditions => { :user_id => self.user_id })
    api_chat_url(sender)
  end

  link :receiver_chat do
    receiver = self.chats.
      find(:first, :conditions => { :user_id => self.contact_id })
    api_chat_url(receiver)
  end

end
