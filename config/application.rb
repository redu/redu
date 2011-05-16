require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Redu
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Brasilia'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # S3 credentials
    if File.exists?("#{Rails.root}/config/s3.yml")
      S3_CONFIG = YAML.load_file("#{Rails.root}/config/s3.yml")
      S3_CREDENTIALS = S3_CONFIG[Rails.env]
    end

    if File.exists?( File.join(Rails.root, 'config', 'application.yml') )
      file = File.join(Rails.root, 'config', 'application.yml')
      config.extras = YAML.load_file file
    end

    # MimeTypes
    if File.exists? File.join(Rails.root, 'config', 'mimetypes.yml')
      file = File.join(Rails.root, 'config', 'mimetypes.yml')
      config.mimetypes = YAML.load_file file
    end

    # Meta dados da aplicação
    config.name = "Redu"
    config.tagline = "A Rede Social Educacional"
    config.description = "A Rede Social Educacional"
    config.email = "contato@redu.com.br"

    # Will paginate
    config.items_per_page = 10

    # Máximo de caracteres p/ descrição
    config.desc_char_limit = 200

    #TODO Confirmar se IE responde
    # codigo usado para o IE aceitar header sem ser html
    #config.action_controller.use_accept_header = false

    config.session_store = :active_record_store

    # ActionMailer
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => 'smtp.gmail.com',
      :port => 587,
      :domain => 'redu.com.br',
      :authentication => :login,
      :user_name => 'no-reply@redu.com.br',
      :password => '7987Y5'
    }

    # Configurações de conversão e storage de videos (Seminar)
    config.video_original = { # Arquivo original do video (uploaded)
      :storage => :s3,
      :s3_credentials => S3_CREDENTIALS,
      :bucket => S3_CREDENTIALS['bucket'],
      :path => ":class/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://redu_assets.s3.amazonaws.com/images/missing_pic.jpg"
    }

    config.video_transcoded = { # Arquivo convertido
      :storage => :s3,
      :s3_credentials => S3_CREDENTIALS,
      :bucket => 'redu_videos',
      :path => ":class/:attachment/:id/:style/:basename.:extension",
      :default_url => "http://redu_assets.s3.amazonaws.com/images/missing_pic.jpg"
    }

    # Usado em :controller => jobs, :action => notify
    config.zencoder_credentials = {
      :username => 'zencoder',
      :password => 'MCZC2pDQyt5bzko1'
    }

    # No ambiente de desenvolvimento :test => 1 (definido em development.rb)
    config.zencoder = {
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

    # Usado pelo WYSIWYG CKEditor
    config.autoload_paths += %W( #{config.root}/app/models/ckeditor )

    # Autoloads code in lib
    config.autoload_paths += %W(#{config.root}/lib)

  end
end
