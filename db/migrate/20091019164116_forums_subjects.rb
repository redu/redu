class ForumsSubjects < ActiveRecord::Migration
  def self.up
     create_table :forums_subjects, :id => false do |t|
      t.integer :forum_id
      t.integer :subject_id
    end
  end

  def self.down
     drop_table :forums_subjects
  end
end
