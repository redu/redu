# -*- encoding : utf-8 -*-
class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.string :hostable_type
      t.integer :hostable_id
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
