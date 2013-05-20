# -*- encoding : utf-8 -*-
class RenameColumnGraduadedToGraduatedInEnrollments < ActiveRecord::Migration
  def self.up
    rename_column :enrollments, :graduaded, :graduated
  end

  def self.down
    rename_column :enrollments, :graduated, :graduaded
  end
end
