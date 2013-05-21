# -*- encoding : utf-8 -*-
class AddBulletinableToBulletins < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :bulletinable_id, :integer
    add_column :bulletins, :bulletinable_type, :string
  end

  def self.down
    remove_column :bulletins, :bulletinable_id
    remove_column :bulletins, :bulletinable_type
  end
end
