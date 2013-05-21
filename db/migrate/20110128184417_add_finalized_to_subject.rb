# -*- encoding : utf-8 -*-
class AddFinalizedToSubject < ActiveRecord::Migration
  def self.up
    add_column :subjects, :finalized, :boolean, :default => false
  end

  def self.down
    remove_column :subjects, :finalized
  end
end
