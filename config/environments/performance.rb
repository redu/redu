Redu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :info

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://#{config.s3_credentials['assets_bucket']}.s3.amazonaws.com"
  # config.action_mailer.asset_host = config.action_controller.asset_host

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Remove cores do log
  config.colorize_logging = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Nome e URL do app
  config.url = "192.168.1.39"
  config.representer.default_url_options = config.url

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_controller.asset_host = "192.168.1.19:3000"

  config.action_mailer.default_url_options = { :host => config.url }
  config.action_mailer.asset_host =  config.action_controller.asset_host

  # Armazena no sist. de arquivos
  config.paperclip = {
    :storage => :filesystem,
    :path => File.join(Rails.root.to_s, "public/images/:class/:attachment/:id/:style/:basename.:extension"),
    :url => "/images/:class/:attachment/:id/:style/:filename",
    :default_url => "/images/new/missing_:class_:style.png"
  }

  config.paperclip_environment.merge!(config.paperclip)
  config.paperclip_user.merge!(config.paperclip)

  config.paperclip_documents = config.paperclip.merge({
    :styles => {},
    :default_url => ''
  })
  config.paperclip_myfiles = config.paperclip.merge({:styles => {}})
  config.video_original = config.paperclip.merge({:styles => {}})
  config.video_transcoded = config.paperclip.merge({:styles => {}})

  # Só converte os 5 primeiros segundos (grátis)
  config.zencoder[:test] = 1

 # Configurações do Pusher (redu-development app)
  config.pusher = {
  }

  # Configuração da aplicação em omniauth providers
  config.omniauth = {
    :facebook => {
      :app_id => '142857189169463',
      :app_secret => 'ea0f249a4df83b250c3364ccf097f35c'
    }
  }

  # Configurações de VisClient
  config.vis_client = {
    :url => "http://localhost:4000/hierarchy_notifications.json",
    :migration => "http://localhost:4000/database_hierarchy_notifications.json"
  }

  config.vis = {
    :subject_activities => "http://localhost:4000/subjects/activities.json",
    :lecture_participation => "http://localhost:4000/lectures/participation.json",
    :students_participation => "http://localhost:4000/user_spaces/participation.json"
  }
end
