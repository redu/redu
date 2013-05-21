# -*- encoding : utf-8 -*-
class AddCnpjToPartner < ActiveRecord::Migration
  def self.up
    add_column :partners, :cnpj, :string
  end

  def self.down
    remove_column :partners, :cnpj
  end
end
