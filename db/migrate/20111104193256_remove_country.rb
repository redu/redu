# -*- encoding : utf-8 -*-
class RemoveCountry < ActiveRecord::Migration
  def self.up
    drop_table :countries
    remove_column :users, :country_id
  end

  def self.down
    create_table "countries", :force => true do |t|
      t.string "name"
    end

    change_table :users do |t|
      t.references :country
    end
  end
end
