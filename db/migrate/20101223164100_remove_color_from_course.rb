# -*- encoding : utf-8 -*-
class RemoveColorFromCourse < ActiveRecord::Migration
  def self.up
    remove_column :courses, :color
  end

  def self.down
    add_column :courses, :color, :string
  end
end
