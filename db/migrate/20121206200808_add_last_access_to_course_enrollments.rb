class AddLastAccessToCourseEnrollments < ActiveRecord::Migration
  def self.up
    add_column :course_enrollments, :last_accessed_at, :datetime
  end

  def self.down
    remove_column :course_enrollments, :last_accessed_at
  end
end
