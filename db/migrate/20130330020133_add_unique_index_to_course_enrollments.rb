class AddUniqueIndexToCourseEnrollments < ActiveRecord::Migration
  def self.up
    add_index :course_enrollments, [:user_id, :course_id, :type],
      :name => :idx_course_enrollments_uid_cid_type, :unique => true
  end

  def self.down
    remove_index :course_enrollments,
      :name => :idx_course_enrollments_uid_cid_type
  end
end
