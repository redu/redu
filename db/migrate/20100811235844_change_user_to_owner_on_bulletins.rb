class ChangeUserToOwnerOnBulletins < ActiveRecord::Migration
  def self.up
    rename_column :bulletins, :user_id, :owner
  end

  def self.down
    rename_column :bulletins, :owner, :user_id
  end
end
