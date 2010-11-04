class AddWorkloadToCourses < ActiveRecord::Migration
  def self.up
    add_column :courses, :workload, :integer
  end

  def self.down
    remove_column :courses, :workload
  end
end
