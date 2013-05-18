module Api
  module ChatMessageAbility
    extend ActiveSupport::Concern

    def chat_message_abilities(user)
      if user
        can :read, ChatMessage, :user_id => user.id
        can :read, ChatMessage, :contact_id => user.id
      end
    end
  end
end

