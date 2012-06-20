source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'bundler', '~> 1.0.15'
gem 'rails', '3.0.10'
gem 'rake', '0.8.7'
gem 'mysql2', '~> 0.2.1'
gem 'authlogic'
gem 'pagseguro', '~> 0.1.10'
gem 'paperclip', '~> 2.7'
gem 'will_paginate', '~> 3.0.pre2'
gem 'mime-types'
gem 'cancan', '~> 1.6.7'
gem 'aasm'
gem 'shuber-sortable'
gem 'scribd_fu', :git => 'git://github.com/guiocavalcanti/scribd_fu.git',
  :branch => 'without-scape'
gem 'factory_girl_rails', '~> 1.7.0'
gem 'ar_mailer_rails3'
gem 'active_enum'
gem 'date_validator'
gem 'deep_cloneable'
gem 'rd_searchlogic', :require => 'searchlogic'
gem 'translate_routes'
gem 'aws-s3', :require => 'aws/s3'
gem 'jquery-rails', '>= 1.0.12'
gem 'dynamic_form'
gem 'ajaxful_rating',
  :git => 'git://github.com/edgarjs/ajaxful-rating.git',
  :branch => 'rails3'
gem 'acts-as-taggable-on'
gem 'ckeditor', '3.4.2.pre'
gem 'jammit-s3'
gem 'whenever', :require => false
gem 'remotipart', '~> 1.0'
gem 'zencoder'
gem 'pusher'
gem 'kaminari'
gem 'simple-navigation'
gem 'actionmailer_inline_css',
  :git => 'git://github.com/ndbroadbent/actionmailer_inline_css.git',
  :branch => 'master'
gem 'acts_as_tree', '~> 0.1.1'
gem 'exceptional'
gem 'awesome_nested_fields'
gem 'invitable', :git => 'git@github.com:redu/invitable.git'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'roar',
  :git => 'https://github.com/apotonick/roar.git'
gem 'roar-rails', '~> 0.0.3',
  :git => 'git://github.com/apotonick/roar-rails.git'
gem 'eventmachine'
gem 'em-http-request'
gem 'delayed_job_active_record',
  :git => 'git://github.com/collectiveidea/delayed_job_active_record.git'
gem 'daemons'
gem 'activerecord-import'
gem 'aws-sdk'
gem "useragent", "~> 0.4.8"
gem 'vis_client', :git => "git@github.com:redu/vis_client.git"
gem 'backup',
  :git => 'git://github.com/meskyanichi/backup.git'
gem 'fog', '~> 1.1.0' # Necessário ao backup

# Gems específicos para a API
gem "oauth-plugin", '~> 0.4.0'
gem 'roar-rails', '~> 0.0.3',
  :git => 'git://github.com/apotonick/roar-rails.git'
gem 'rack-cors', :require => 'rack/cors'

# Gems específicos de algum ambiente
group :development, :test do
  gem 'rspec-rails', '~> 2.8'
  gem 'shoulda-matchers'
  gem 'ruby-debug'
  gem 'jasmine'
  gem 'no_peeping_toms', :git => 'git://github.com/patmaddox/no-peeping-toms.git'
  gem 'rails3-generators'
end

group :test do
  gem 'webmock', '~> 1.8.6'
  gem 'capybara'
  gem 'launchy'
  gem 'database_cleaner'
end

group :development do
  gem 'thin'
  gem 'rails-footnotes', '>= 3.7.5.rc4'
end

group :production do
  gem 'newrelic_rpm', '3.0.1'
end

