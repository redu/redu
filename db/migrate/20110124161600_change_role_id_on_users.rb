# -*- encoding : utf-8 -*-
class ChangeRoleIdOnUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :role_id, :integer, :default => 2
  end

  def self.down
    change_column :users, :role_if, :integer, :default => 3
  end
end
