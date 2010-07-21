class InsertUsers < ActiveRecord::Migration
  def self.up
   
     theuser = User.create(:login => 'test_user', 
          :email => 'test_user@example.com',
          :password => 'redutest123',
          :password_confirmation => 'redutest123',
          :birthday => 20.years.ago,
          :first_name => 'Test',
          :last_name => 'User',
          :role_id => 3)  
    
    puts theuser.login
     
     
    theadmin = User.create(:login => 'administrator', 
          :email => 'admin@example.com',
          :password => 'reduadmin123',
          :password_confirmation => 'reduadmin123',
          :birthday => 20.years.ago,
          :first_name => 'Admin',
          :last_name => 'Redu',
          :role_id => 1)  
    
    puts theadmin.login
  
  end

  def self.down
  end
end
