# -*- encoding : utf-8 -*-
class RemovePathFromSpaces < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :path
  end

  def self.down
    add_column :spaces, :path, :string
  end
end
