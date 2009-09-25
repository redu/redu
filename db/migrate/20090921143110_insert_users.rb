class InsertUsers < ActiveRecord::Migration
  def self.up
    User.create(:login => 'teste', 
          :email => 'teste@example.com',
          :password => 'teste123',
          :password_confirmation => 'teste123',
          :birthday => 14.years.ago)
          
    User.create(:login => 'administrator', 
          :email => 'admin@example.com',
          :password => 'admin123',
          :password_confirmation => 'admin123',
          :birthday => 14.years.ago)       
    
    
  end

  def self.down
  end
end
