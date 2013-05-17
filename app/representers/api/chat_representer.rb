module Api
  module ChatRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :created_at
    property :updated_at

    link :self do
      api_chat_url(self)
    end

    link :user do
      api_user_url(self.user)
    end

    link :contact do
      api_user_url(self.contact)
    end

    link :chat_messages do
      api_chat_messages_url(self)
    end
  end
end
