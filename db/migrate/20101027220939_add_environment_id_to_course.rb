# -*- encoding : utf-8 -*-
class AddEnvironmentIdToCourse < ActiveRecord::Migration
  def self.up
    add_column :courses, :environment_id, :integer
  end

  def self.down
    remove_column :courses, :environment_id
  end
end
