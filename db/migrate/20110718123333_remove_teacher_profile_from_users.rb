class RemoveTeacherProfileFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :teacher_profile
  end

  def self.down
    add_column :users, :teacher_profile, :boolean
  end
end
