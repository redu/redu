# -*- encoding : utf-8 -*-
class RemovePublicFromExams < ActiveRecord::Migration
  def self.up
    remove_column :exams, :public
  end

  def self.down
    add_column :exams, :public, :integer
  end
end
