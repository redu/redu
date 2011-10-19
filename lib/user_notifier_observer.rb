class UserNotifierObserver
  def self.delivered_email(message)
    html = message.html_part.body.to_s
    File.open("#{Rails.root}/tmp/#{message.message_id}.html", 'w') do |mail|
      mail.write(html)
    end
  end
end
