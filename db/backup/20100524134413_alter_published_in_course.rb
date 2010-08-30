class AlterPublishedInCourse < ActiveRecord::Migration
  def self.up
    change_column(:courses, :published, :boolean, {:default => false})
  end

  def self.down
  end
end
