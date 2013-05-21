# -*- encoding : utf-8 -*-
class RemovePriceFromExam < ActiveRecord::Migration
  def self.up
    remove_column :exams, :price
  end

  def self.down
    add_column :exams, :price, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end
end
