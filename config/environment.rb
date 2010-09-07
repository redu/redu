# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'desert'
require 'ostruct'
require 'yaml'
require "validatable"


Rails::Initializer.run do |config|

  # S3 credentials
  if File.exists?("#{RAILS_ROOT}/config/s3.yml")
    S3_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/s3.yml")
    S3_CREDENTIALS = S3_CONFIG[Rails.env]
  end
  
  if File.exists?( File.join(RAILS_ROOT, 'config', 'application.yml') )
    file = File.join(RAILS_ROOT, 'config', 'application.yml')
    users_app_config = YAML.load_file file
  end
  default_app_config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'application.yml'))
  
  config_hash = (users_app_config||{}).reverse_merge!(default_app_config)
  
  unless defined?(AppConfig)
    ::AppConfig = OpenStruct.new config_hash
  else
    orig_hash   = AppConfig.marshal_dump
    merged_hash = config_hash.merge(orig_hash)
    
    AppConfig = OpenStruct.new merged_hash
  end
  

  config.action_controller.session_store = :active_record_store
  
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.action_mailer.raise_delivery_errors = true
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      #:enable_starttls_auto => true,
      :address => 'smtp.gmail.com',
      :port => 587,
      :domain => 'www.gmail.com',
      :authentication => :login,
      :user_name => 'diagnosticarapuama@gmail.com',
      :password => 'apuamaeth0'
  }  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = 'pt-BR' # ver arquivo globalite.rb
end
#require "#{RAILS_ROOT}/vendor/plugins/community_engine/config/boot.rb"

#OpenSocialContainer::Configuration.person_class = 'User'
#OpenSocialContainer::Configuration.secret = 'secret_password'

WillPaginate::ViewHelpers.pagination_options[:prev_label] = 'Anterior'  
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Próximo'
WillPaginate::ViewHelpers.pagination_options[:separator] = nil
WillPaginate::ViewHelpers.pagination_options[:renderer] = 'PaginationListLinkRenderer'



