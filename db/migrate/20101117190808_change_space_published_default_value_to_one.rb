# -*- encoding : utf-8 -*-
class ChangeSpacePublishedDefaultValueToOne < ActiveRecord::Migration
  def self.up
    change_column_default :spaces, :published, true
  end

  def self.down
    change_column_default :spaces, :published, false
  end
end
