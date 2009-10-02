class CreateCourseSubjectAssociations < ActiveRecord::Migration
  def self.up
    create_table :course_subject_associations do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :course_subject_associations
  end
end
