class AddExternalResourceTypeToResource < ActiveRecord::Migration
  def self.up
    add_column :resources, :external_resource_type, :string
  end

  def self.down
    remove_column :resources, :external_resource_type
  end
end
