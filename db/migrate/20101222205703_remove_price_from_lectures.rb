# -*- encoding : utf-8 -*-
class RemovePriceFromLectures < ActiveRecord::Migration
  def self.up
    remove_column :lectures, :price
  end

  def self.down
    add_column :lectures, :price, :decimal
  end
end
