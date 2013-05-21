# -*- encoding : utf-8 -*-
class RemoveUca < ActiveRecord::Migration
  def self.up
    drop_table :user_course_associations
  end

  def self.down
    create_table "user_course_associations", :force => true do |t|
      t.integer  "user_id"
      t.integer  "course_id"
      t.integer  "role"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state"
    end

    add_index "user_course_associations", ["role", "state"], :name => "index_user_course_associations_on_role_and_state"
    add_index "user_course_associations", ["role"], :name => "index_user_course_associations_on_role"
    add_index "user_course_associations", ["state", "course_id"], :name => "index_user_course_associations_on_course_and_state"
    add_index "user_course_associations", ["state"], :name => "index_user_course_associations_on_state"

    ActiveRecord::Observer.disable_observers
    UserCourseAssociation.reset_column_information

    query_ce = <<-eos
      SELECT course_id, user_id, state, created_at, updated_at, role
      FROM course_enrollments
      WHERE type LIKE 'UserCourseAssociation';
    eos

    UserCourseAssociation.find_by_sql(query_ce).each do |ce|
      values = <<-eos
        #{ce.user_id}, #{ce.course_id}, '#{ce.role}',
        '#{ce.created_at.utc.to_formatted_s(:db)}',
        '#{ce.updated_at.utc.to_formatted_s(:db)}', '#{ce.state}'
      eos

      sql = <<-eos
        INSERT
        INTO user_course_associations (`user_id`, `course_id`, `role`,
                                       `created_at`, `updated_at`, `state`)
        VALUES (#{values});
      eos
      conn = ActiveRecord::Base.connection.execute(sql)
    end && nil
  end
end
