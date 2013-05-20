# -*- encoding : utf-8 -*-
class CreateChatMessages < ActiveRecord::Migration
  def self.up
    create_table :chat_messages do |t|
      t.references :user
      t.integer :contact_id
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :chat_messages
  end
end
