# -*- encoding : utf-8 -*-
class RenameAttributesFromSchoolToSpace < ActiveRecord::Migration
  def self.up
    rename_column :redu_categories_spaces, :school_id, :space_id
    rename_column :audiences_spaces, :school_id, :space_id
    rename_column :space_assets, :school_id, :space_id
    rename_column :user_space_associations, :school_id, :space_id
    rename_column :bulletins, :school_id, :space_id
    rename_column :group_permissions, :school_id, :space_id
    rename_column :roles, :school_role, :space_role
    rename_column :subjects, :school_id, :space_id
  end

  def self.down
    rename_column :redu_categories_spaces, :space_id, :school_id
    rename_column :audiences_spaces, :space_id, :school_id
    rename_column :space_assets, :space_id, :school_id
    rename_column :bulletins, :school_id, :space_id
    rename_column :group_permissions, :space_id,  :school_id
    rename_column :roles, :space_role, :school_role
    rename_column :subjects, :space_id, :school_id
    rename_column :user_space_associations, :school_id, :space_id
  end
end
