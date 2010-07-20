class AddCourseIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :course_id, :integer, :null => false
  end

  def self.down
  end
end
