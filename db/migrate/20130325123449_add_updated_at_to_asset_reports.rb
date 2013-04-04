class AddUpdatedAtToAssetReports < ActiveRecord::Migration
  def self.up
    add_column :asset_reports, :updated_at, :datetime
  end

  def self.down
    remove_column :asset_reports, :updated_at
  end
end
