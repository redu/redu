Permit.configure do |config|
  config.logger = Rails.logger
  config.deliver_messages = !(Rails.env.test? || Rails.env.development?)
  config.deliver_messages = true
  config.service_name = 'core'
end
