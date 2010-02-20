class RemoveUserIdCredits < ActiveRecord::Migration
  def self.up
    remove_column :credits, :user_id
  end

  def self.down
    add_column :credits, :user_id, :integer
  end
end
