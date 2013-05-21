# -*- encoding : utf-8 -*-
class AddYearlyValueToPlan < ActiveRecord::Migration
  def self.up
    add_column :plans, :yearly_price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :plans, :yearly_price
  end
end
