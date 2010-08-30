class AddTimeToExamUsers < ActiveRecord::Migration
  def self.up
    add_column :exam_users, :time, :integer
  end

  def self.down
  end
end
