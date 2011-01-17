# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.6' unless defined? RAILS_GEM_VERSION

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
  # codigo usado para o IE aceitar header sem ser html
  config.action_controller.use_accept_header = false

  config.action_controller.session_store = :active_record_store
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      #:enable_starttls_auto => true,
      :address => 'smtp.gmail.com',
      :port => 587,
      :domain => 'redu.com.br',
      :authentication => :login,
      :user_name => 'no-reply@redu.com.br',
      :password => '7987Y5'
  }

  # Configurações de conversão e storage de videos (Seminar)
    # Arquivo original do video (uploaded)
    VIDEO_ORIGINAL = {
      :storage => :s3,
      :s3_credentials => S3_CREDENTIALS,
      :bucket => S3_CREDENTIALS['bucket'],
      :path => "seminar/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://redu_assets.s3.amazonaws.com/images/missing_pic.jpg"
    }

    # Arquivo convertido
    VIDEO_TRANSCODED = {
      :storage => :s3,
      :s3_credentials => S3_CREDENTIALS,
      :bucket => 'redu_videos',
      :path => "seminar/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://redu_assets.s3.amazonaws.com/images/missing_pic.jpg"
    }

    # No ambiente de desenvolvimento :test => 1 (definido em development.rb)
    ZENCODER_CONFIG = {
      :api_key => 'cf950c35c3943ff7c25a84c874ddcca3',
      :input => '',
      :output => {
        :url => '',
        :video_codec => "vp6",
        :public => 1,
        :thumbnails => {
          :number => 6,
          :size => "160x120",
          :base_url => '',
          :prefix => "thumb"
        },
        :notifications => {
            :format => 'json',
            :url => ''
        }
      }
    }

    # Usado em :controller => jobs, :action => notify
    ZENCODER_CREDENTIALS = {
      :username => 'zencoder',
      :password => 'MCZC2pDQyt5bzko1'
    }

  # Usado pelo WYSIWYG CKEditor
  config.load_paths += %W( #{RAILS_ROOT}/app/models/ckeditor )

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Brasilia'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = 'pt-BR' # ver arquivo globalite.rb
end

#OpenSocialContainer::Configuration.person_class = 'User'
#OpenSocialContainer::Configuration.secret = 'secret_password'

WillPaginate::ViewHelpers.pagination_options[:prev_label] = 'Anterior'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Próximo'
WillPaginate::ViewHelpers.pagination_options[:separator] = nil
WillPaginate::ViewHelpers.pagination_options[:renderer] = 'PaginationListLinkRenderer'



