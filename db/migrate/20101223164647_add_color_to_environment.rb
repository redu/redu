# -*- encoding : utf-8 -*-
class AddColorToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :color, :string, :default => "34cdf9"
  end

  def self.down
    remove_column :environments, :color
  end
end
