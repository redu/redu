# -*- encoding : utf-8 -*-
class ChangePublishedDefaultOnCourse < ActiveRecord::Migration
  def self.up
    change_column_default :courses, :published, true
  end

  def self.down
    change_column_default :courses, :published, false
  end
end
