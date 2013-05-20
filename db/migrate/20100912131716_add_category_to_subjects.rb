# -*- encoding : utf-8 -*-
class AddCategoryToSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :simple_category_id, :integer
  end

  def self.down
  end
end
