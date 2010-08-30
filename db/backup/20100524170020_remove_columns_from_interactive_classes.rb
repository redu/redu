class RemoveColumnsFromInteractiveClasses < ActiveRecord::Migration
  def self.up
  remove_column :interactive_classes, :name
  remove_column :interactive_classes, :tagline
  remove_column :interactive_classes, :description
  add_column :interactive_classes, :course_id, :integer, :null => false

  end

  def self.down
  end
end
