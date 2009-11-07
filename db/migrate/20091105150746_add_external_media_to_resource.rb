class AddExternalMediaToResource < ActiveRecord::Migration
  def self.up
    add_column :resources, :external_resource, :string
  end

  def self.down
    remove_column :resources, :external_resource
  end
end
