# -*- encoding : utf-8 -*-
class CreateChatMessageAssociations < ActiveRecord::Migration
  def self.up
    create_table :chat_message_associations do |t|
      t.references :chat
      t.references :chat_message

      t.timestamps
    end
    add_index :chat_message_associations, :chat_id
    add_index :chat_message_associations, :chat_message_id
  end

  def self.down
    drop_table :chat_message_associations
  end
end
