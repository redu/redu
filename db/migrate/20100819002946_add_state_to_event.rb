class AddStateToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :state, :string
  end

  def self.down
    remove_column :events, :state
  end
end
