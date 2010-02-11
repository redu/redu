class AddViewCountToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :view_count, :integer, :default => 0
  end

  def self.down
    remove_column :courses, :view_count
  end
end
