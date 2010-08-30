class AllowCourseIdNullInPages < ActiveRecord::Migration
  def self.up
    change_column(:pages, :course_id, :integer, :null => true)
  end

  def self.down
  end
end
