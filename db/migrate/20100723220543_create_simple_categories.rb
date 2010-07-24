class CreateSimpleCategories < ActiveRecord::Migration
  def self.up
    create_table :simple_categories do |t|
       t.string :name, :null => :false
      #t.timestamps
    end
     
     categories = ['Arts / Design / Animation', 'Beauty / Fashion', 'Business / Economics / Law', 'Cars / Bikes', 'Health / Wellness / Relationships', 'Hobbies / Gaming',
'Home / Gardening', 'Languages', 'Music', 'Nutrition / Food / Drinks', 'Online Marketing', 'Religion / Philosophy', 'Science / Technology / Engineering',
'Society / History / Politics', 'Sports', 'Other']

  categories.each do |category|
     SimpleCategory.create(:name => category)
   end
    
  end

  def self.down
    drop_table :simple_categories
  end
end
