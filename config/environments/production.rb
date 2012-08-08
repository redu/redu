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
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  config.action_controller.asset_host = "http://#{config.s3_credentials['assets_bucket']}.s3.amazonaws.com"
  config.action_mailer.asset_host = config.action_controller.asset_host

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Nome e URL do app
  config.url = "www.redu.com.br"

  config.action_mailer.default_url_options = \
    { :host => config.url }
  config.representer.default_url_options = { :host => config.url }

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Remove cores do log
  config.colorize_logging = false

  # Configuração da aplicação em omniauth providers
  config.omniauth = {
    :facebook => {
      :app_id => '191555477625856',
      :app_secret => '27e285f90a3ee1db7a3b61641ae14694'
    }
  }

  # Configurações de VisClient
  config.vis_client = {
   :url => "http://vis.redu.com.br/hierarchy_notifications.json",
   :migration => "http://vis.redu.com.br/database_hierarchy_notifications.json"
 }

  config.vis = {
    :subject_activities => "http://vis.redu.com.br/subjects/activities.json",
    :lecture_participation => "http://vis.redu.com.br/lectures/participation.json",
    :students_participation => "http://vis.redu.com.br/user_spaces/participation.json"
  }

end
