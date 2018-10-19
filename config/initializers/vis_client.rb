# -*- encoding : utf-8 -*-
VisClient.configure do |config|
  config.deliver_notifications = true
  config.logger = Rails.logger
  config.endpoint = Redu::Application.config.vis_client[:host] if (Rails.env.development? || Rails.env.test?)
end
