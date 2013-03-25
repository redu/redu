VisClient.configure do |config|
  config.deliver_notifications = !(Rails.env.development?)
  config.logger = Rails.logger
  config.endpoint = Redu::Application.config.vis_client[:host]
end
