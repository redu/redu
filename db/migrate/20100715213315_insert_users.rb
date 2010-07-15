class InsertUsers < ActiveRecord::Migration
  def self.up
=begin
    User.create(:login => 'teste', 
          :email => 'teste@example.com',
          :password => 'teste123',
          :password_confirmation => 'teste123',
          :birthday => 14.years.ago)
       
=end         
    theuser = User.create(:login => 'administrator', 
          :email => 'admin@example.com',
          :password => 'reduadmin123',
          :password_confirmation => 'reduadmin123',
          :birthday => 20.years.ago,
          :first_name => 'Admin',
          :last_name => 'Redu',
          :role_id => 1)  
    
    puts theuser.login
  
  end

  def self.down
  end
end
