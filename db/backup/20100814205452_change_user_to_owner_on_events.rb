class ChangeUserToOwnerOnEvents < ActiveRecord::Migration
  def self.up
    rename_column :events, :user_id, :owner
  end

  def self.down
    rename_column :events, :owner, :user_id
  end
end
