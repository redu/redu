class AddUniqueIndexToSpaces < ActiveRecord::Migration
  def self.up
    add_index :user_space_associations, [:user_id, :space_id], :unique => true
  end

  def self.down
    remove_index :user_space_associations, :column => [:user_id, :space_id]
  end
end
