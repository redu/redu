class AddStateToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :state, :string
  end

  def self.down
    remove_column :courses, :state
  end
end
