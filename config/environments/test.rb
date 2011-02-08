# Settings specified here will take precedence over those in config/environment.rb
APP_URL = "http://localhost:3000" 
require 'ruby-debug'
# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

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

VIDEO_ORIGINAL = PAPERCLIP_STORAGE_OPTIONS
DOCUMENT_STORAGE_OPTIONS = PAPERCLIP_STORAGE_OPTIONS
PAPERCLIP_MYFILES_OPTIONS = PAPERCLIP_STORAGE_OPTIONS

# Só converte os 5 primeiros segundos (grátis)
ZENCODER_CONFIG[:test] = 1

  config.gem 'rspec-rails', :version => '>= 1.3.3', :lib => false unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
