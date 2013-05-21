# -*- encoding : utf-8 -*-
class RemoveIsPublicFromSubjects < ActiveRecord::Migration
  def self.up
    remove_column :subjects, :is_public
  end

  def self.down
    add_column :subjects, :is_public, :boolean
  end
end
