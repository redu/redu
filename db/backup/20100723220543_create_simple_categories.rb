class CreateSimpleCategories < ActiveRecord::Migration
  def self.up
    create_table :simple_categories do |t|
       t.string :name, :null => :false
      #t.timestamps
    end
  end

  def self.down
    drop_table :simple_categories
  end
end
