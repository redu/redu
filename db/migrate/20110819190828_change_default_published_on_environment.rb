# -*- encoding : utf-8 -*-
class ChangeDefaultPublishedOnEnvironment < ActiveRecord::Migration
  def self.up
    change_column_default :environments, :published, true
  end

  def self.down
    change_column_default :environments, :published, false
  end
end
