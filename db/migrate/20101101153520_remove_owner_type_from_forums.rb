# -*- encoding : utf-8 -*-
class RemoveOwnerTypeFromForums < ActiveRecord::Migration
  def self.up
    remove_column :forums, :owner_type
  end

  def self.down
    add_column :forums, :owner_type, :string
  end
end
