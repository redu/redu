namespace :redu do
  desc "Redu specific recipes"
  task :essential do
    run "sudo apt-get -y install build-essential"
    run "sudo apt-get -y install apache2 apache2-prefork-dev libapr1-dev libaprutil1-dev"
    run "sudo apt-get -y install ruby ruby-dev rubygems1.8"
    run "sudo apt-get -y install libopenssl-ruby"
    run "sudo apt-get -y install imagemagick libmagick++-dev"
    run "sudo apt-get install mysql-server libmysqlclient-dev"
  end
  
  desc "Build Subversion from source (1.4.4) due to incomatibility problems"
  task :build_svn do
    run "cd ~"
    run "rm -rf subversion*"
    run "wget http://subversion.tigris.org/downloads/subversion-1.4.4.tar.gz"
    run "wget http://subversion.tigris.org/downloads/subversion-deps-1.4.4.tar.gz"
    run "tar xzvf subversion-1.4.4.tar.gz && tar xzvf subversion-deps-1.4.4.tar.gz"
    run "cd subversion-1.4.4"
    run "./configure && make && sudo make install"
  end
  
  desc "Redu specific Gems"
  task :install_gems do
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
  end
  
  desc "Setting PATHS"
  task :set_path do
    #TODO
    # export PATH=$PATH:$HOME/.gems/
  end
end  
