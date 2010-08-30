class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
      t.column :school_role, :boolean , :null => false
    end

    remove_column :users, :admin
    add_column :users, :role_id, :integer
  end

  def self.down
    drop_table :roles
    remove_column :users, :role_id
    add_column :users, :admin, :boolean, :default => false
  end
end
