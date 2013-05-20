# -*- encoding : utf-8 -*-
class RemoveIsCloneFromPage < ActiveRecord::Migration
  def self.up
    remove_column :pages, :is_clone
  end

  def self.down
    add_column :pages, :is_clone, :boolean
  end
end
