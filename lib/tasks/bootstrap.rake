namespace :bootstrap do
  desc "Add the default admin"
  task :default_admin => :environment do
    theadmin = User.create(:login => 'administrator', 
      :email => 'admin@example.com',
      :password => 'reduadmin123',
      :password_confirmation => 'reduadmin123',
      :birthday => 20.years.ago,
      :first_name => 'Admin',
      :last_name => 'Redu',
      :role_id => 1)
  end

  desc "Create the default user"
  task :default_user => :environment do
    theuser = User.create(:login => 'test_user', 
      :email => 'test_user@example.com',
      :password => 'redutest123',
      :password_confirmation => 'redutest123',
      :birthday => 20.years.ago,
      :first_name => 'Test',
      :last_name => 'User',
      :role_id => 3)
  end

  desc "Run all bootstrapping tasks"
  task :all => [:default_user, :default_admin]
end