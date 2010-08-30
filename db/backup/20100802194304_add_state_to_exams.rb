class AddStateToExams < ActiveRecord::Migration
  def self.up
    add_column :exams, :state, :string
   end

  def self.down
  end
end
