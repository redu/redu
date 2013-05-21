# -*- encoding : utf-8 -*-
class ChangeLoginUserIndexToUnique < ActiveRecord::Migration
  def self.up
    remove_index :users, :name => "index_users_on_login"
    add_index :users, :login, :unique => true,
      :name => "index_users_on_login"
  end

  def self.down
    remove_index :users, :name => "index_users_on_login"
    add_index :users, :login, :name => "index_users_on_login"
  end
end
