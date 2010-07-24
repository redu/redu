class CreateReduCategories < ActiveRecord::Migration
  def self.up
    create_table :redu_categories do |t|
      t.string :name, :null => :false
      
     # t.timestamps
   end
   
   categories = ['Aeronautics and Astronautics', 'Anthropology', 'Architecture', 'Automotive', 'Biology', 'Business and Management', 'Chemistry', 
'Civil and Environmental Engineering', 'Communication', 'Comparative Media Studies', 'Criminal Justice', 
'Culinary Arts', 'Earth Atmospheric and Planetary Sciences', 'Economics', 'Education', 'Electrical Engineering and Computer Science',
'Elementary Math', 'Elementary Reading', 'Elementary Spelling', 'Environmental Studies', 'Foreign Languages', 'Health Sciences', 'History',
'Hobbies', 'Homeschool', 'Hospitality', 'How-to', 'Journalism', 'Library Science', 'Linguistics', 'Literature', 'Materials Science and Engineering',
'Mathematics', 'Mechanical Engineering', 'Media Arts', 'Miscellaneous', 'Music and Theater Arts', 'Nuclear Science and Engineering', 
'Nursing', 'Nutrition', 'Philosophy', 'Physical Education', 'Physics', 'Political Science', 'Psychology', 'Religion and Spirituality',
'Self-help', 'Sociology', 'Systems Engineering', 'Test-Prep', 'Trades', 'Unit Studies', 'Urban Studies and Planning', "Women's and Gender Studies",
'Writing']

   
   categories.each do |category|
     ReduCategory.create(:name => category)
   end
   
   
  end

  def self.down
    drop_table :redu_categories
  end
end
