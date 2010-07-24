class CreateCategoriesSchools < ActiveRecord::Migration
  def self.up
    create_table :redu_categories_schools, :id => false do |t|
       t.integer :redu_category_id
       t.integer :school_id
      #t.timestamps
    end
  end

  def self.down
    drop_table :redu_categories_schools
  end
end
