class AddUniqueIndexToEnrollmentsAndAssetReports < ActiveRecord::Migration
  def self.up
    add_index :status_user_associations, [:user_id, :status_id],
      :unique => true
    add_index :asset_reports, [:enrollment_id, :lecture_id],
      :unique => true
  end

  def self.down
    remove_index :status_user_associations, :column => [:user_id, :status_id]
    remove_index :asset_reports, :column => [:enrollment_id, :lecture_id]
  end
end
