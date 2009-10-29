class ResourcesSubjects < ActiveRecord::Migration
  def self.up
    create_table :resources_subjects, :id => false do |t|
      t.integer :resource_id
      t.integer :subject_id
    end
  end

  def self.down
    drop_table :resources_subjects
  end
end
