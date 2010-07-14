class AddRemoved < ActiveRecord::Migration
  def self.up
    add_column :courses, :removed, :boolean, :default => false
    add_column :users, :removed, :boolean, :default => false
    add_column :schools, :removed, :boolean, :default => false
    add_column :exams, :removed, :boolean, :default => false
  end

  def self.down
#    remove_column :courses, :removed
#    remove_column :users, :removed
#    remove_column :schools, :removed
#    remove_column :exams, :removed
  end
end
