# -*- encoding : utf-8 -*-
class AddTaglineToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :tagline, :string
  end

  def self.down
    remove_column :events, :tagline
  end
end
