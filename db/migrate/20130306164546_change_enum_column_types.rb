# -*- encoding : utf-8 -*-
class ChangeEnumColumnTypes < ActiveRecord::Migration
  def self.up
    %w(course_enrollments enrollments users user_environment_associations user_space_associations).each do |table|
      change_column table, :role, :string, :default => nil
    end

    change_column :user_settings, :view_mural, :string
  end

  def self.down
    %w(course_enrollments enrollments users user_environment_associations user_space_associations).each do |table|
      change_column table, :role, :integer, :default => nil
    end
    change_column :user_settings, :view_mural, :integer
  end
end
