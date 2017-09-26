class ChatsController < ApplicationController
	def send_message
		receiver = User.find(params['contact_id'])
    authorize! :send_message, receiver
		text = params['text']

		sender(
			"/#{receiver.user_channel}",
			{
				user_id: current_user.id,
				name: "#{current_user.first_name} #{current_user.last_name}",
				thumbnail: current_user.avatar.url(:thumb_24),
				text: text
			}
		)
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
