class MergeLogsToStatuses < ActiveRecord::Migration
  def self.up
    add_column :statuses, :log, :boolean, :default => false
    add_column :statuses, :logeable_type, :string
    add_column :statuses, :logeable_id, :integer
    add_column :statuses, :log_action, :string
    add_column :statuses, :logeable_name, :string
      
  end

  def self.down
  end
end
