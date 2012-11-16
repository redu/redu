Untied::Publisher.configure do |config|
  config.deliver_messages = !(Rails.env.test? || Rails.env.development?)
  # config.deliver_messages = true
  config.logger = Rails.logger
  config.service_name = "core"
  config.doorkeeper = ::BaseDoorkeeper
end
