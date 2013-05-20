# -*- encoding : utf-8 -*-
class RemoveStateFromLectures < ActiveRecord::Migration
  def self.up
    remove_column :lectures, :state
  end

  def self.down
    add_column :lectures, :state, :string
  end
end
