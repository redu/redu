class AddUserToBulletin < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :user_id, :integer
  end

  def self.down
    remove_column :bulletins, :user_id
  end
end
