# -*- encoding : utf-8 -*-
class ChangeViewMuralIdToViewMuralInUserSettings < ActiveRecord::Migration
  def self.up
    rename_column :user_settings, :view_mural_id, :view_mural
  end

  def self.down
    rename_column :user_settings, :view_mural, :view_mural_id
  end
end
