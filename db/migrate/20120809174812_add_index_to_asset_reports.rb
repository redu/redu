class AddIndexToAssetReports < ActiveRecord::Migration
  def self.up
    add_index :asset_reports, :enrollment_id
    add_index :asset_reports, :lecture_id
  end

  def self.down
    remove_index :asset_reports, :column => :enrollment_id
    remove_index :asset_reports, :column => :lecture_id
  end
end
