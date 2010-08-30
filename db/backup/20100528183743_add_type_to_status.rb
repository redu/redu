class AddTypeToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :kind, :integer
  end

  def self.down
    remove_column :statuses, :kind
  end
end
