namespace :redu do
  desc "Redu specific recipes"
  task :essential do
    run "sudo apt-get -y install build-essential"
    run "sudo apt-get -y install apache2 apache2-prefork-dev libapr1-dev libaprutil1-dev"
    run "sudo apt-get -y install ruby ruby-dev rubygems1.8 irb"
    run "sudo apt-get -y install libopenssl-ruby"
    run "sudo apt-get -y install imagemagick libmagick++-dev"
    # TODO precisa ser setado manualmente
    # run "sudo apt-get install mysql-server libmysqlclient-dev"
  end
  
  desc "Build Subversion from source (1.4.4) due to incomatibility problems"
  task :build_svn do
    run "cd ~"
    run "rm -rf subversion*"
    #TODO não mostrar progresso
    stream "wget http://subversion.tigris.org/downloads/subversion-1.4.4.tar.gz"
    stream "wget http://subversion.tigris.org/downloads/subversion-deps-1.4.4.tar.gz"
    run "tar xzvf subversion-1.4.4.tar.gz && tar xzvf subversion-deps-1.4.4.tar.gz"
    run "cd subversion-1.4.4 && ./configure && make && sudo make install"
    run "rm -rf subversion*"
  end
  
  desc "Redu specific Gems"
  task :install_gems do
    #TODO Precisa ser configurado manualmente
    run "gem install passenger"
    run "gem install rake"
    run "gem install rails -v=2.3.5 --no-rdoc"
    run "gem install desert --no-rdoc"
    run "gem install packet --no-rdoc"
    run "gem install brcobranca --no-rdoc"
    run "gem install parseline --no-rdoc"
    run "gem install tiny_mce --no-rdoc"
    run "gem install calendar_date_select --no-rdoc"
    run "gem install icalendar --no-rdoc"
    run "gem install will_paginate -v=2.3.11 --no-rdoc"
    run "gem install adzap-ar_mailer"
    run "gem install haml --no-rdoc"
    run "gem install mysql --no-rdoc"
    run "gem install hpricot --no-rdoc"
    run "gem install htmlentities --no-rdoc"
    run "gem install rmagick -v=2.13.1"
    run "gem install authlogic --no-rdoc"
    run "gem install oauth --no-rdoc"
    run "gem install authlogic-oauth --no-rdoc"
    run "gem install right_aws --no-ri --no-rdoc"
  end
  
  desc "Create base dir with the right owner"
  task :dirs do
    run "cd / && sudo mkdir u && sudo chown -R ubuntu u"
  end
    
  desc "Sets Gem PATHS"
  task :set_path do
    run "echo \"export PATH=$PATH:$HOME/home/ubuntu/.gem/ruby/1.8/bin\" >> ~/.bashrc"
  end
  
  desc "Push static files to S3"
  task :s3commit do
    run "export SSL_CERT_DIR=$HOME/certs && cd #{current_path} && #{rake} s3commit"
  end
  
  after "deploy:update" do
    run "export SSL_CERT_DIR=$HOME/certs && cd #{current_path} && #{rake} s3commit"
  end
  
  before "deploy:update" do
    run "cd #{current_path} && #{rake} RAILS_ENV=production s3:backup:db"
  end
  
  desc "Run bootstrap rake task"
  task :bootstrap do
    run "cd #{current_path} && #{rake} RAILS_ENV=production bootstrap:all"
  end
  
  desc "Streams error log file"
  task :errors do
    stream "tail -f #{current_path}/log/error.log"
  end
  
  desc "Starts delayed_job server"
  task :delayed_jobs_start do
    run ""
  end
end  
