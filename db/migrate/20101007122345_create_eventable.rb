class CreateEventable < ActiveRecord::Migration
  def self.up
    remove_column :events, :space_id
    add_column :events, :eventable_id, :integer
    add_column :events, :eventable_type, :string
  end

  def self.down
    add_column :events, :space_id, :integer
    remove_column :events, :eventable_id
    remove_column :events, :eventable_type
  end
end
