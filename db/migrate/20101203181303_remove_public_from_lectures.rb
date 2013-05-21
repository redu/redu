# -*- encoding : utf-8 -*-
class RemovePublicFromLectures < ActiveRecord::Migration
  def self.up
    remove_column :lectures, :public
  end

  def self.down
    add_column :lectures, :public, :boolean
  end
end
