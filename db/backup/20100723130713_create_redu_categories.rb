class CreateReduCategories < ActiveRecord::Migration
  def self.up
    create_table :redu_categories do |t|
      t.string :name, :null => :false
      
     # t.timestamps
   end  
  end

  def self.down
    drop_table :redu_categories
  end
end
