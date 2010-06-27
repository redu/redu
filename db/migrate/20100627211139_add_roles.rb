class AddRoles < ActiveRecord::Migration
  def self.up
    Role.enumeration_model_updates_permitted = true
    Role.create(:name => 'admin', :school_role => false)    
    Role.create(:name => 'moderator', :school_role => false)
    Role.create(:name => 'member', :school_role => false)   
    
    # school roles
    Role.create(:name => 'school_admin', :school_role => true)
    Role.create(:name => 'coordinator', :school_role => true)  
    Role.create(:name => 'teacher', :school_role => true)
    Role.create(:name => 'student', :school_role => true)
    
    
    Role.enumeration_model_updates_permitted = false
    #set all existing users to 'member'
    User.update_all("role_id = #{Role[:member].id}")
  end

  def self.down
  end
end
