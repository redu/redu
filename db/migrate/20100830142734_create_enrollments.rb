class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.integer :user_id
      t.integer :course_id
      t.timestamps
    end

    #execute "alter table enrollments add constraint fk_enrollment_user
    #foreign key (user_id) references users(id)"

    #execute "alter table enrollments add constraint fk_enrollment_course
    #foreign key (course_id) references courses(id)"


  end

  def self.down

    #execute "ALTER TABLE enrollments DROP FOREIGN KEY fk_enrollment_user"

    #execute "ALTER TABLE enrollments DROP FOREIGN KEY fk_enrollment_course"
 

    drop_table :enrollments
  end
end
