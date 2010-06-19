class RemoveCourseIdInPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :course_id
  end

  def self.down
  end
end
