# -*- encoding : utf-8 -*-
class AddLectureIdToAssetReport < ActiveRecord::Migration
  def self.up
    add_column :asset_reports, :lecture_id, :integer
  end

  def self.down
    remove_column :asset_reports, :lecture_id
  end
end
