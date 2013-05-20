# -*- encoding : utf-8 -*-
class RemoveColorAndThemeFromEnvironment < ActiveRecord::Migration
  def self.up
    remove_column :environments, :color
    remove_column :environments, :theme
  end

  def self.down
    add_column :environments, :color, :string, :default => "4DADD6"
    add_column :environments, :theme, :string
  end
end
