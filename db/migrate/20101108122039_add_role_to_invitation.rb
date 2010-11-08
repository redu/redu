class AddRoleToInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, :role_id, :integer
  end

  def self.down
    remove_column :invitations, :role_id
  end
end
