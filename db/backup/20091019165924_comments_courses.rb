class CommentsCourses < ActiveRecord::Migration
  def self.up
     create_table :comments_courses, :id => false do |t|
      t.integer :comment_id
      t.integer :course_id
    end
  end

  def self.down
     drop_table :comments_courses
  end
end
