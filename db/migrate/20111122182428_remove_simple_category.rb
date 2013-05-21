# -*- encoding : utf-8 -*-
class RemoveSimpleCategory < ActiveRecord::Migration
  def self.up
    drop_table :simple_categories
  end

  def self.down
    create_table "simple_categories", :force => true do |t|
      t.string "name"
    end
  end
end
