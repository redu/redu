class AddUserToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :user_id, :integer
  end

  def self.down
    add_column :statuses, :user_id
  end
end
