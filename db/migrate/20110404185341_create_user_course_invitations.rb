# -*- encoding : utf-8 -*-
class CreateUserCourseInvitations < ActiveRecord::Migration
  def self.up
    create_table :user_course_invitations do |t|
      t.string :token, :null => false
      t.string :email, :null => false
      t.references :user
      t.references :course, :null => false
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :user_course_invitations
  end
end
