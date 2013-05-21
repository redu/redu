# -*- encoding : utf-8 -*-
class RemoveMetroAreas < ActiveRecord::Migration
  def self.up
    drop_table :metro_areas
    remove_column :users, :metro_area_id
  end

  def self.down
    create_table "metro_areas", :force => true do |t|
      t.string  "name"
      t.integer "state_id"
      t.integer "country_id"
      t.integer "users_count", :default => 0
    end

    change_table :users do |t|
      t.belongs_to :metro_area
    end
  end
end
