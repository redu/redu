# -*- encoding : utf-8 -*-
class ChangePublishedOnSubjectsToFalse < ActiveRecord::Migration
  def self.up
    change_column_default :subjects, :published, false
  end

  def self.down
    change_column_default :subjects, :published, true
  end
end
