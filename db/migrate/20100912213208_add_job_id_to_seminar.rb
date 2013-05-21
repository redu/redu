# -*- encoding : utf-8 -*-
class AddJobIdToSeminar < ActiveRecord::Migration
  def self.up
    add_column :seminars, :job, :integer
  end

  def self.down
    remove_column :seminars, :job
  end
end
