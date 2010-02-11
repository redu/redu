# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'desert'
require 'ostruct'
require 'yaml'  
#require 'community_engine'
#config.active_record.observers = :course_observer, :resource_observer


Rails::Initializer.run do |config|
  
=begin  
  config.plugins = [:community_engine, :white_list, :all]
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine/plugins"]
=end
  
  #config.plugins = [:community_engine, :white_list, :all]
  #config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/community_engine/plugins"]
  config.gem 'calendar_date_select'
  config.gem 'icalendar'        
  config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
  # config.active_record.observers = :course_observer, :resource_observer
  
  
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
  
  ActiveRecord::Base.send(:extend, CommunityEngine::ActiveRecordExtensions)
=begin
  config.action_controller.session = {
    :key    => '_your_app_session',
    :secret => '75bb655faa4386fd061de6b576c4a3115fa2a380343359d3f0ab1c0a1be1e70e2cf7f4ecd14131f923570e8e5573331070802ebb5f8b543e2ba93d79b819419a'
  }
=end
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
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
#require "#{RAILS_ROOT}/vendor/plugins/community_engine/config/boot.rb"

WillPaginate::ViewHelpers.pagination_options[:prev_label] = 'Anterior'  
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Próximo'
WillPaginate::ViewHelpers.pagination_options[:separator] = nil
WillPaginate::ViewHelpers.pagination_options[:renderer] = 'PaginationListLinkRenderer'

require 'rails_asset_extensions'
