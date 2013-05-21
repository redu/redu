# -*- encoding : utf-8 -*-
class CreateCourseEnrollments < ActiveRecord::Migration
  def self.up
    create_table :course_enrollments do |t|
      t.references :user
      t.references :course
      t.string :state
      t.string :token
      t.string :email
      t.integer :role
      t.string :type

      t.timestamps
    end

    add_index "course_enrollments", ["role", "state"], :name => "index_user_course_associations_on_role_and_state"
    add_index "course_enrollments", ["role"], :name => "index_user_course_associations_on_role"
    add_index "course_enrollments", ["state", "course_id"], :name => "index_user_course_associations_on_course_and_state"
    add_index "course_enrollments", ["state"], :name => "index_user_course_associations_on_state"
    add_index "course_enrollments", ["token"], :name => "index_user_course_associations_on_token"

    query_uca = <<-eos
      SELECT course_id, user_id, state, created_at, updated_at, role
      FROM user_course_associations;
    eos

    query_uci = <<-eos
      SELECT course_id, email, token, state, created_at, updated_at
      FROM user_course_invitations;
    eos

    UserCourseAssociation.find_by_sql(query_uca).each do |uca|
      ActiveRecord::Base.record_timestamps = false
      new_uca = UserCourseAssociation.new(uca.attributes)
      new_uca.type = 'UserCourseAssociation'
      new_uca.state = uca.state
      new_uca.save
    end && nil

    UserCourseInvitation.find_by_sql(query_uci).each do |uci|
      ActiveRecord::Base.record_timestamps = false
      UserCourseInvitation.before_validation.clear
      new_uci = UserCourseInvitation.new(uci.attributes)
      new_uci.type = 'UserCourseInvitation'
      new_uci.save
    end && nil

  end

  def self.down
    drop_table :course_enrollments
  end
end
