class AddCompoundedAndCompoundedIdToStatuses < ActiveRecord::Migration
  def self.up
    add_column :statuses, :compound, :boolean
    add_column :statuses, :compound_log_id, :integer
  end

  def self.down
    remove_column :statuses, :compound_log_id
    remove_column :statuses, :compound
  end
end
