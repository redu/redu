# -*- encoding : utf-8 -*-
class ChangeDefaultPublishedOnSubjectToTrue < ActiveRecord::Migration
  def self.up
    change_column_default :subjects, :published, true
  end

  def self.down
    change_column_default :subjects, :published, false
  end
end
