# -*- encoding : utf-8 -*-
class AddOwnerToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :owner, :integer

  end

  def self.down
    remove_column :courses, :owner
  end
end
