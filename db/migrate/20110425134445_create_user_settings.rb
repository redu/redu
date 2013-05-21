# -*- encoding : utf-8 -*-
class CreateUserSettings < ActiveRecord::Migration
  def self.up
    create_table :user_settings do |t|
      t.references :user
      t.integer :view_mural_id
    end
  end

  def self.down
    drop_table :user_settings
  end
end
