# -*- encoding : utf-8 -*-
class RemoveOwnerIdFromForums < ActiveRecord::Migration
  def self.up
    remove_column :forums, :owner_id
  end

  def self.down
    add_column :forums, :owner_id, :integer
  end
end
