class AddRatingAverageToCourses < ActiveRecord::Migration
def self.up
  add_column :courses, :rating_average, :decimal, :default => 0
end

def self.down
  remove_column :courses, :rating_average
end
end
