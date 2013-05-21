# -*- encoding : utf-8 -*-
class AddSourceToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :source, :string
  end

  def self.down
  end
end
