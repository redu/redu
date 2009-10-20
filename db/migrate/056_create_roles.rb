class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
      t.column :school_role, :boolean , :null => false
    end

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
    
    add_column :users, :role_id, :integer

    #set all existing users to 'member'
    User.update_all("role_id = #{Role[:member].id}", ["admin = ?", false])
    #set admins to 'admin'
    User.update_all("role_id = #{Role[:admin].id}", ["admin = ?", true])    

    remove_column :users, :admin
  end

  def self.down
    drop_table :roles
    remove_column :users, :role_id
    add_column :users, :admin, :boolean, :default => false
  end
end
