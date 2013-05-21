# -*- encoding : utf-8 -*-
class AddHasInvitedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :auto_status, :boolean, :default => true
    add_column :users, :has_invited, :boolean, :default => false
    add_column :users, :teacher_profile, :boolean, :default => false
    rename_column :users, :notify_comments, :notify_messages
    rename_column :users, :notify_friend_requests, :notify_followships
  end

  def self.down
    
  end
end
