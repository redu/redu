# Settings specified here will take precedence over those in config/environment.rb
APP_URL = "http://localhost:3000" 
# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false
config.log_level = :error

# para ver as queries realizadas no console, digite esta linha no console: ActiveRecord::Base.logger = Logger.new(STDOUT) 
#ActiveRecord::Base.logger = Logger.new(STDOUT)

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

PAPERCLIP_STORAGE_OPTIONS = {:default_url => '/images/missing_pic.jpg'}