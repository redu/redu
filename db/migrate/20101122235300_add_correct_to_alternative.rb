# -*- encoding : utf-8 -*-
class AddCorrectToAlternative < ActiveRecord::Migration
  def self.up
    add_column :alternatives, :correct, :boolean, :default => false
  end

  def self.down
    remove_column :alternatives, :correct
  end
end
