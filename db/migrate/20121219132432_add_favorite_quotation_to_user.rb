# -*- encoding : utf-8 -*-
class AddFavoriteQuotationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :favorite_quotation, :text
  end

  def self.down
    remove_column :users, :favorite_quotation
  end
end
