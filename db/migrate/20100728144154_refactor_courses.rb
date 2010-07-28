class RefactorCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :courseable_type, :string
    add_column :courses, :courseable_id, :integer
    
    remove_column :courses, :main_resource_id
    remove_column :courses, :media_file_name
    remove_column :courses, :media_content_type
    remove_column :courses, :media_file_size
    
    remove_column :courses, :external_resource
    remove_column :courses, :external_resource_type
    remove_column :courses, :course_type
    
    remove_column :seminars, :course_id
    remove_column :pages, :course_id
    remove_column :interactive_classes, :course_id
    
    remove_column :seminars, :state
    
    Course.destroy_all
    InteractiveClass.destroy_all
    Page.destroy_all
    
    
  end

  def self.down
  end
end
