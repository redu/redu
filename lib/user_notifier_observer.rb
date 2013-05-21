# -*- encoding : utf-8 -*-
class UserNotifierObserver
  def self.delivered_email(message)
    html = message.html_part
    return nil unless html

    File.open("#{Rails.root}/tmp/#{message.message_id}.html", 'w') do |mail|
      mail.write(html.body.to_s)
    end
  end
end
