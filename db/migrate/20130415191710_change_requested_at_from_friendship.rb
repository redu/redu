class ChangeRequestedAtFromFriendship < ActiveRecord::Migration
  def self.up
    change_column :friendships, :requested_at, :datetime, :null => false
  end

  def self.down
  end
end
