class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :subjects
  end
end
