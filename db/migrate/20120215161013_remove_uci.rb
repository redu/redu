# -*- encoding : utf-8 -*-
class RemoveUci < ActiveRecord::Migration
  def self.up
    drop_table :user_course_invitations
  end

  def self.down
    create_table "user_course_invitations", :force => true do |t|
      t.string   "token",      :null => false
      t.string   "email",      :null => false
      t.integer  "user_id"
      t.integer  "course_id",  :null => false
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    ActiveRecord::Observer.disable_observers
    UserCourseAssociation.reset_column_information

    query_ce = <<-eos
      SELECT token, email, user_id, course_id, state, created_at, updated_at
      FROM course_enrollments
      WHERE type LIKE 'UserCourseInvitation';
    eos

    UserCourseInvitation.find_by_sql(query_ce).each do |ce|
      values = <<-eos
        '#{ce.token}', '#{ce.email}', #{ce.user_id.nil? ? 'NULL' : ce.user_id},
        #{ce.course_id}, '#{ce.state}', '#{ce.created_at.utc.to_formatted_s(:db)}',
        '#{ce.updated_at.utc.to_formatted_s(:db)}'
      eos

      sql = <<-eos
        INSERT
        INTO user_course_invitations (`token`, `email`, `user_id`,
                                       `course_id`, `state`,
                                       `created_at`, `updated_at`)
        VALUES (#{values});
      eos
      conn = ActiveRecord::Base.connection.execute(sql)
    end && nil
  end
end
