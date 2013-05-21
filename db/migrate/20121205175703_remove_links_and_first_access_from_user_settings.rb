# -*- encoding : utf-8 -*-
class RemoveLinksAndFirstAccessFromUserSettings < ActiveRecord::Migration
  def self.up
    remove_column :user_settings, :first_access
    remove_column :user_settings, :profile
    remove_column :user_settings, :friends
    remove_column :user_settings, :message
    remove_column :user_settings, :course
    remove_column :user_settings, :environment
    remove_column :user_settings, :basic_guide
  end

  def self.down
    add_column :user_settings, :first_access, :boolean, :default => true
    add_column :user_settings, :profile, :boolean, :default => true
    add_column :user_settings, :friends, :boolean, :default => true
    add_column :user_settings, :message, :boolean, :default => true
    add_column :user_settings, :course, :boolean, :default => true
    add_column :user_settings, :environment, :boolean, :default => true
    add_column :user_settings, :basic_guide, :boolean, :default => true
  end
end
