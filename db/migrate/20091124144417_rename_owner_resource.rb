class RenameOwnerResource < ActiveRecord::Migration
  def self.up
    rename_column :resources, :owner, :owner_id
  end

  def self.down
  end
end
