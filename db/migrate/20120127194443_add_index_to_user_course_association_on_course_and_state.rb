# -*- encoding : utf-8 -*-
class AddIndexToUserCourseAssociationOnCourseAndState < ActiveRecord::Migration
  def self.up
    add_index "user_course_associations", ["state", "course_id"], :name => "index_user_course_associations_on_course_and_state"
  end

  def self.down
    remove_index "user_course_associations", :name => "index_user_course_associations_on_course_and_state"
  end
end
