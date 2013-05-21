# -*- encoding : utf-8 -*-
class ChangeTextOnStatusesToText < ActiveRecord::Migration
  def self.up
    change_column :statuses, :text, :text
  end

  def self.down
    change_column :statuses, :text, :string
  end
end
