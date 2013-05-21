# -*- encoding : utf-8 -*-
class AddDestroySoonToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :destroy_soon, :boolean, :default => false
    add_index :environments, :destroy_soon
  end

  def self.down
    remove_column :environments, :destroy_soon
  end
end
