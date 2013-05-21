# -*- encoding : utf-8 -*-
class AddIsCloneToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_clone, :boolean, :default => true
  end

  def self.down
    remove_column :pages, :is_clone
  end
end
