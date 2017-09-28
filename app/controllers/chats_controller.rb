class ChatsController < ApplicationController
	def send_message
		recipient = User.find(params['contact_id'])

    authorize! :send_message, recipient

    text = params['text']
    conversation = Conversation.first_or_create(sender: current_user, recipient: recipient)
    p conversation
    message = conversation.chat_messages.build(user: current_user, body: text)

    if message.valid?
      sender("/#{recipient.user_channel}", message.format_message)
    end

		head :ok, content_type: "text/html"
	end

  def online
    authorize! :online, :chats
    sender(
      "/online/client",
      {
        'user_id' => current_user.id,
        'avatar' => current_user.avatar.url(:thumb_24),
        'name' => "#{current_user.first_name} #{current_user.last_name}"
      }
    )
    head :ok, content_type: "text/html"
  end

  protected

  	def sender(channel, msg)
      message = {:channel => channel, :data => msg.merge(:authToken => 'openredu')}
      uri = URI.parse("http://localhost:9292/faye")
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
end
