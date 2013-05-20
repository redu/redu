# -*- encoding : utf-8 -*-
class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.references :user
      t.references :contact

      t.timestamps
    end
    add_index :chats, :user_id
    add_index :chats, :contact_id
  end

  def self.down
    drop_table :chats
  end
end
