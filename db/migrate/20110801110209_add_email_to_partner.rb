# -*- encoding : utf-8 -*-
class AddEmailToPartner < ActiveRecord::Migration
  def self.up
    add_column :partners, :email, :string
  end

  def self.down
    remove_column :partners, :email
  end
end
