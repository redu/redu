# -*- encoding : utf-8 -*-
class AddPositionToLecture < ActiveRecord::Migration
  def self.up
    add_column :lectures, :position, :integer
  end

  def self.down
    remove_column :lectures, :position
  end
end
