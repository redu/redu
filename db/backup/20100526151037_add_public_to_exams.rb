class AddPublicToExams < ActiveRecord::Migration
  def self.up
    add_column :exams, :public, :boolean, :default => true
  end

  def self.down
  end
end
