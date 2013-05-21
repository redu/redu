# -*- encoding : utf-8 -*-
class AddAddressToPartners < ActiveRecord::Migration
  def self.up
    add_column :partners, :address, :string
  end

  def self.down
    remove_column :partners, :address
  end
end
