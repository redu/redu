class CreateReduCategories < ActiveRecord::Migration
  def self.up
    create_table :redu_categories do |t|
      t.string :name, :null => :false
      
     # t.timestamps
   end
   
   categories = ["Aeronautics and Astronautics", "Anthropology", "", ""]
   
   
   ReduCategory.create(:name => "Aeronautics and Astronautics")
   
  
   
   
   
   
  end

  def self.down
    drop_table :redu_categories
  end
end
