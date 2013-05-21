# -*- encoding : utf-8 -*-
class AddLocalizationAndLanguagesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birth_localization, :string
    add_column :users, :languages, :string
  end

  def self.down
    remove_column :users, :birth_localization
    remove_column :users, :languages
  end
end
