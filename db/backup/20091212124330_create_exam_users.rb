class CreateExamUsers < ActiveRecord::Migration
  def self.up
    create_table :exam_users do |t|
      t.integer :user_id
      t.integer :exam_id
      t.datetime :done_at
      t.integer :correct_count, :default => 0
      t.boolean :public, :default => false
     # t.timestamps
    end
  end

  def self.down
    drop_table :exam_users
  end
end
