class CreateUserCompetences < ActiveRecord::Migration
  def self.up
    create_table :user_competences do |t|
      t.integer :user_id, :null => false
      t.integer :skill_id, :null => false
      t.integer :done_count, :default => 0
      t.integer :correct_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :user_competences
  end
end
