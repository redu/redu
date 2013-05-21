# -*- encoding : utf-8 -*-
class RemoveState < ActiveRecord::Migration
  def self.up
    drop_table :states
    remove_column :users, :state_id
  end

  def self.down
    create_table "states", :force => true do |t|
      t.string "name"
    end

    change_table :users do |t|
      t.references :state
    end
  end
end
