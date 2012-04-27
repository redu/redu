class AddCompoundAndCompoundLogIdAndCompoundVisibleAtToStatuses < ActiveRecord::Migration
  def self.up
    add_column :statuses, :compound, :boolean, :default => false
    add_column :statuses, :compound_log_id, :integer
    add_column :statuses, :compound_visible_at, :datetime
  end

  def self.down
    remove_column :statuses, :compound_log_id
    remove_column :statuses, :compound
    remove_column :statuses, :compound_visible_at, :datetime
  end
end
