class AddSchollIdToLogs < ActiveRecord::Migration
  def self.up
     add_column :logs, :school_id, :integer
  end

  def self.down
    remove_column :logs, :school_id
  end
end
