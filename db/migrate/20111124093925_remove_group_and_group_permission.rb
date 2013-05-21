# -*- encoding : utf-8 -*-
class RemoveGroupAndGroupPermission < ActiveRecord::Migration
  def self.up
    drop_table :group_permissions
    drop_table :groups
  end

  def self.down
    create_table "groups", :force => true do |t|
      t.string  "name"
      t.boolean "is_the_administrators_group", :default => false
    end
    create_table "group_permissions", :force => true do |t|
      t.integer "folder_id"
      t.integer "group_id"
      t.integer "school_id"
      t.boolean "can_create", :default => false
      t.boolean "can_read",   :default => false
      t.boolean "can_update", :default => false
      t.boolean "can_delete", :default => false
    end
  end
end
