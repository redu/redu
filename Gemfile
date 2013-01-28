source 'http://rubygems.org'
source 'http://gems.github.com'
source 'http://reduadmin:pomp64bozos@the-shire.herokuapp.com/'

group :assets do
  gem 'compass-rails'
end

gem 'aasm'
gem 'actionmailer_inline_css',
  :git => 'git://github.com/ndbroadbent/actionmailer_inline_css.git',
  :branch => 'master'
gem 'active_enum'
gem 'activerecord-import'
gem 'acts_as_tree', '~> 0.1.1'
gem 'acts-as-taggable-on'
gem 'ajaxful_rating',
  :git => 'git://github.com/edgarjs/ajaxful-rating.git',
  :branch => 'rails3'
gem 'ar_mailer_rails3'
gem 'authlogic'
gem 'awesome_nested_fields'
gem 'aws-s3', :require => 'aws/s3'
gem 'aws-sdk'
gem 'backup',
  :git => 'git://github.com/meskyanichi/backup.git'
gem 'bundler', '~> 1.2'
gem 'cancan', '~> 1.6.7'
gem 'ckeditor', '3.4.2.pre'
gem 'daemons'
gem 'date_validator'
gem 'mongoid', '~> 2.2.6', :require => 'mongoid/version'
gem 'deep_cloneable'
gem 'delayed_job_mongoid'
gem 'bson_ext'
gem 'dynamic_form'
gem 'em-http-request'
gem 'eventmachine'
gem 'exceptional'
gem 'factory_girl_rails', '~> 1.7.0'
gem 'fog', '~> 1.1.0' # Necessário ao backup
gem 'invitable', :git => 'git@github.com:redu/invitable.git'
gem 'jammit-s3'
gem 'jquery-rails', '>= 1.0.12'
gem 'kaminari'
gem 'mime-types'
gem 'mysql2', '~> 0.2.1'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'pusher'
gem 'pagseguro', '~> 0.1.10'
gem 'paperclip', '~> 2.7'
gem 'rails', '~> 3.0.20'
gem 'rake', '0.8.7'
gem 'rd_searchlogic', :require => 'searchlogic'
gem 'remotipart', '~> 1.0'
gem 'scribd_fu', :git => 'git://github.com/guiocavalcanti/scribd_fu.git',
  :branch => 'without-scape'
gem 'shuber-sortable'
gem 'simple-navigation', :git => 'git://github.com/andi/simple-navigation.git'
gem 'translate_routes'
gem 'useragent', '~> 0.4.8'
gem 'vis_client', :git => 'git@github.com:redu/vis_client.git'
gem 'whenever', :require => false
gem 'will_paginate', '~> 3.0.pre2'
gem 'zencoder'
gem 'untied-publisher', :git => 'git://github.com/redu/untied-publisher'
gem 'content_for_in_controllers',
  :git => 'git://github.com/julianalucena/content_for_in_controllers.git'
gem 'system_timer'

# Gems específicos para a API
gem 'oauth-plugin', '~> 0.4.0'
gem 'rack-cors', :require => 'rack/cors'
gem 'roar-rails'
gem 'roar'
gem 'destroy_soon'
gem 'redu_analytics'
gem 'humanizer'

# Gems específicos de algum ambiente
group :development, :test do
  gem 'jasmine'
  gem 'no_peeping_toms', :git => 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'rails3-generators'
  gem 'rspec-rails', '~> 2.8'
  gem 'ruby-debug'
  gem 'shoulda-matchers'
end

group :test do
  gem 'webmock', :git => 'git://github.com/fltiago/webmock'
  gem 'ruby-prof'
end

group :development do
  # gem 'uniform_notifier'

  # Gems úteis p/ análise performance
  # gem 'bullet'
  # gem 'rack-mini-profiler', '0.1.10'
  # gem 'rails-footnotes', '>= 3.7.5.rc4'
end

group :production do
  gem 'newrelic_rpm', '3.0.1'
end
