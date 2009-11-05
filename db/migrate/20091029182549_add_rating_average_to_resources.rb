class AddRatingAverageToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :rating_average, :decimal, :default => 0
  end

  def self.down
    remove_column :resources, :rating_average
  end
end
