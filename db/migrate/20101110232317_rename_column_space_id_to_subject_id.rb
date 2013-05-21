# -*- encoding : utf-8 -*-
class RenameColumnSpaceIdToSubjectId < ActiveRecord::Migration
  def self.up
		rename_column :subject_assets, :space_id, :subject_id
  end

  def self.down
		rename_column :subject_assets, :subject_id, :space_id
  end
end
