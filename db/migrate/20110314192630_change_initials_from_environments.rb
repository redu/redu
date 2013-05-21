# -*- encoding : utf-8 -*-
class ChangeInitialsFromEnvironments < ActiveRecord::Migration
  def self.up
    change_column :environments, :initials, :string, :limit => 80, :null => false
  end

  def self.down
    change_column :environments, :initials, :string
  end
end
