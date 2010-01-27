class AddExternalResourceToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :external_resource, :string
    add_column :courses, :external_resource_type, :string
  end

  def self.down
    remove_column :courses, :external_resource_type
    remove_column :courses, :external_resource
  end
end
