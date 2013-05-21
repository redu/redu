# -*- encoding : utf-8 -*-
class RemoveCategoryFromLecturesAndExams < ActiveRecord::Migration
  def self.up
    remove_column :lectures, :simple_category_id
    remove_column :exams, :simple_category_id
  end

  def self.down
    add_column :lectures, :simple_category_id, :integer
    add_column :exams, :simple_category_id, :integer
  end
end
