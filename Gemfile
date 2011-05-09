source "http://rubygems.org"
source "http://gems.github.com"

# Colocado, pois todas as validações de modelo estavam com a mensagem: {{attribute}} {{message}}
gem 'i18n', "~> 0.4.0"

gem "rails", "2.3.8"
gem "desert"
gem "rake", "0.8.7"
gem "validatable"
gem "mysql"
gem "authlogic"
gem "parseline"
gem "icalendar"
gem "will_paginate", "~> 2.3.11"
gem "adzap-ar_mailer"
gem "oauth"
gem "rmagick", "2.12.2"
gem "packet"
gem "hpricot"
gem "htmlentities", "4.2.1"
gem "ruby-debug", "0.10.3"
gem "zencoder"
gem "mime-types"
gem "haml"
gem "cancan", "1.4.1"
gem "rscribd"
gem "scribd_fu", :git => "git://github.com/guiocavalcanti/scribd_fu.git"
gem "ghazel-daemons"
gem "delayed_job", :git => "git://github.com/collectiveidea/delayed_job.git",
  :branch => "v2.0"
gem "factory_girl"
gem "aws-s3", :require => "aws/s3"
gem "paperclip", "~> 2.3"
gem "right_aws", "~> 2.0.0"
gem "shuber-sortable"
gem "abstract", "1.0.0"
gem "erubis", "2.6.6"
gem "whenever", :require => false
gem "clicktale", :git => "git://github.com/astrails/clicktale.git"

group :development do
  gem "mongrel"
  gem "aanand-deadweight"
  gem "faker"
end

group :production do
  gem "newrelic_rpm", "2.13.1"
end

group :staging do
end

group :test do
  gem "rspec", "~> 1.3"
  gem "rspec-rails", "~> 1.3"
  gem "shoulda"
end
