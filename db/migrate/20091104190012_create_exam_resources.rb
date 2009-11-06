class CreateExamResources < ActiveRecord::Migration
  def self.up
     create_table :exams_resources, :id => false do |t|
      t.integer :exam_id
      t.integer :resource_id
    end
  end

  def self.down
    drop_table :exams_resources
  end
end
