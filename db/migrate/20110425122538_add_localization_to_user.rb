# -*- encoding : utf-8 -*-
class AddLocalizationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :localization, :string
  end

  def self.down
    remove_column :users, :localization
  end
end
