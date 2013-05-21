# -*- encoding : utf-8 -*-
class AddInitialsToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :initials, :string
  end

  def self.down
    remove_column :environments, :initials
  end
end
