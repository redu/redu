# -*- encoding : utf-8 -*-
class RemovePublicFromSeminars < ActiveRecord::Migration
  def self.up
    remove_column :seminars, :public
  end

  def self.down
    remove_column :seminars, :public, :boolen
  end
end
