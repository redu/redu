# Settings specified here will take precedence over those in config/environment.rb
APP_URL = "http://localhost:3000" 
# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false
config.log_level = :debug

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

# Armazena no sist. de arquivos
PAPERCLIP_STORAGE_OPTIONS = {
  :path => "public/system/:class/:attachment/:id/:style/:basename.:extension",
  :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
  :default_url => "new/missing_:class_:style.png",
  :styles => { :medium => "220x220>",
               :thumb => "140x140>",
               :small => "60x60>",
               :nano => "24x24>",
               :thumb_150 => "150x150>",
               :thumb_120 => "120x120>",
               :thumb_100 => "100x100>",
               :thumb_32 => "32x32>" }
}

VIDEO_ORIGINAL = PAPERCLIP_STORAGE_OPTIONS.delete(:styles)
DOCUMENT_STORAGE_OPTIONS = PAPERCLIP_STORAGE_OPTIONS
PAPERCLIP_MYFILES_OPTIONS = PAPERCLIP_STORAGE_OPTIONS

# Só converte os 5 primeiros segundos (grátis)
ZENCODER_CONFIG[:test] = 1


