class AddInstructionToExam < ActiveRecord::Migration
  def self.up
    add_column :exams, :instruction, :text
    add_column :exams, :level, :integer, :default => 2
  end

  def self.down
    remove_column :exams, :instruction
    remove_column :exams, :level
  end
end
