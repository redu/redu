class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.integer :user_id
      t.integer :course_id
      t.integer :role_id
      t.references :enrollmentable, :polymorphic => true
      t.timestamps
    end

    #execute "alter table enrollments add constraint fk_enrollment_user
    #foreign key (user_id) references users(id)"

    #execute "alter table enrollments add constraint fk_enrollment_course
    #foreign key (course_id) references courses(id)"

    #execute "alter table enrollments add constraint fk_enrollment_role
    #foreign key (role_id) references roles(id)"

  end

  def self.down

    #execute "ALTER TABLE enrollments DROP FOREIGN KEY fk_enrollment_user"

    #execute "ALTER TABLE enrollments DROP FOREIGN KEY fk_enrollment_course"

    #execute "ALTER TABLE enrollments DROP FOREIGN KEY fk_enrollment_role"

    drop_table :enrollments
  end
end
