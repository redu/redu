# -*- encoding : utf-8 -*-
class RemoveKeyPriceFromSpace < ActiveRecord::Migration
  def self.up
    remove_column :spaces, :key_price
  end

  def self.down
    add_column :spaces, :key_price, :decimal
  end
end
