class AddCategoryToCoursesQuestions < ActiveRecord::Migration
  def self.up
    remove_column :questions, :skill_id
    add_column :questions, :category_id
    add_column :questions, :subcategory_id
    add_column :questions, :subsubcategory_id
    
   # add_column :course, :category_id
   # add_column :course, :subcategory_id
   # add_column :course, :subsubcategory_id
    
    
  end

  def self.down
  end
end
