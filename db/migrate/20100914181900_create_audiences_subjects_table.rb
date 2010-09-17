class CreateAudiencesSubjectsTable < ActiveRecord::Migration
  def self.up
    create_table :audiences_subjects do |t|
      t.integer :audience_id
      t.integer :subject_id
      t.timestamps
    end
  end

  def self.down
    drop_table :audiences_subjects
  end
end
