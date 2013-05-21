# -*- encoding : utf-8 -*-
class ChangeFilesAndMultimediaFromQuotas < ActiveRecord::Migration
  def self.up
    change_column :quotas, :files, :integer, :default => 0 
    change_column :quotas, :multimedia, :integer, :default => 0  
  end

  def self.down
    change_column :quotas, :files, :integer
    change_column :quotas, :multimedia, :integer
  end
end
