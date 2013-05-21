# -*- encoding : utf-8 -*-
class RemoveSubmissionTypeAndThemeFromSpace < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :submission_type
    remove_column :spaces, :theme
  end

  def self.down
    add_column :spaces, :submission_type, :integer
    add_column :spaces, :theme, :string, :default => "default"
  end
end
