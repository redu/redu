class AddUniqueIndexToEnrollments < ActiveRecord::Migration
  def self.up
    add_index :enrollments, [:user_id, :subject_id], :unique => true
  end

  def self.down
    remove_index :enrollments, :column => [:user_id, :subject_id]
  end
end
