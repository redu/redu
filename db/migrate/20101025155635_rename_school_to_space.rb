# -*- encoding : utf-8 -*-
class RenameSchoolToSpace < ActiveRecord::Migration
  def self.up
    rename_table :schools, :spaces
    rename_table :user_school_associations, :user_space_associations
    rename_table :audiences_schools, :audiences_spaces
    rename_table :redu_categories_schools, :redu_categories_spaces
    rename_table :school_assets, :space_assets
  end

  def self.down
    rename_table :spaces, :schools
    rename_table :user_space_associations, :user_school_associations
    rename_table :audiences_spaces, :audiences_schools
    rename_table :redu_categories_spaces, :redu_categories_schools
    rename_table :space_assets, :school_assets
  end
end
