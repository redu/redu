class SetDefaultRoleIdToUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :role_id, :integer, :default => 3
  end

  def self.down
  end
end
