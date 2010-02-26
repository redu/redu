class RenameTitleToNameInResources < ActiveRecord::Migration
  def self.up
    rename_column :resources, :title, :name
  end

  def self.down
    rename_column :resources, :name, :title
  end
end
