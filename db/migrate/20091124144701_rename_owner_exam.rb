class RenameOwnerExam < ActiveRecord::Migration
  def self.up
    rename_column :exams, :author_id, :owner_id
  end

  def self.down
  end
end
