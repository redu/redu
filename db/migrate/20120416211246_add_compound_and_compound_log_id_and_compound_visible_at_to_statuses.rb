# -*- encoding : utf-8 -*-
class AddCompoundAndCompoundLogIdAndCompoundVisibleAtToStatuses < ActiveRecord::Migration
  def self.up
    add_column :statuses, :compound, :boolean, :default => false
    add_column :statuses, :compound_log_id, :integer
    add_column :statuses, :compound_visible_at, :datetime

    add_index :statuses, [:compound], :name => 'index_statuses_compound'
    add_index :statuses, [:compound_log_id], :name => 'index_statuses_compound_log_id'
    add_index :statuses, [:compound_visible_at], :name => 'index_statuses_compound_visible_at'
  end

  def self.down
    remove_column :statuses, :compound_log_id
    remove_column :statuses, :compound
    remove_column :statuses, :compound_visible_at, :datetime
  end
end
