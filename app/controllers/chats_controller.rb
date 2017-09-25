class ChatsController < ApplicationController
	def send_message
		receiver = User.find(params['contact_id'])
		text = params['text']

		sender(
			"/#{receiver.user_channel}",
			{
				user_id: current_user.id,
				name: current_user.first_name,
				thumbnail: current_user.avatar.url(:thumb_24),
				text: text
			}
		)
		head :ok, content_type: "text/html"
	end

	def sender(channel, msg)
    message = {:channel => channel, :data => msg}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end
