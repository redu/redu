# -*- encoding : utf-8 -*-
class AddSubjectIdToLecture < ActiveRecord::Migration
  def self.up
    add_column :lectures, :subject_id, :integer
  end

  def self.down
    remove_column :lectures, :subject_id
  end
end
