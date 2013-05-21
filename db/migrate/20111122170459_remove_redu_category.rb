# -*- encoding : utf-8 -*-
class RemoveReduCategory < ActiveRecord::Migration
  def self.up
  	drop_table :redu_categories
  end

  def self.down
    create_table "redu_categories", :force => true do |t|
      t.string "name"
    end
  end
end
