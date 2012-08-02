class AddHasBasicContentToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :has_basic_content, :boolean

    add_index :courses, [:has_basic_content], :name => 'index_basic_content_courses'
  end

  def self.down
    remove_column :courses, :has_basic_content
  end
end
