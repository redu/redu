namespace :redu do
  desc "Authlogic"
  task :reset_passwords => :environment do
    User.update_all("crypted_password = 'a9bd0bc808e198563ca149b4b6d8ee02c133769c', password_salt = 'dGDx00NCZaM8JizrXs'" )
  end
end