# -*- encoding : utf-8 -*-
class AddRoleToEnrollments < ActiveRecord::Migration
  def self.up
     add_column :enrollments, :role_id, :integer, :default => 7 #student
  end

  def self.down
  end
end
