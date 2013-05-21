# -*- encoding : utf-8 -*-
class AddTaglineToBulletins < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :tagline, :string
  end

  def self.down
    remove_column :bulletins, :tagline
  end
end
