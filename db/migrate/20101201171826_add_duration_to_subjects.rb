# -*- encoding : utf-8 -*-
class AddDurationToSubjects < ActiveRecord::Migration
  def self.up
    add_column :subjects, :duration, :integer
  end

  def self.down
    remove_column :subjects, :duration
  end
end
