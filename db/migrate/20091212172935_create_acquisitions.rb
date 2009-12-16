class CreateAcquisitions < ActiveRecord::Migration
  def self.up
    create_table :acquisitions do |t|
      t.integer :course_id
      t.references :acquired_by, :polymorphic => true
      #t.string :acquired
      t.timestamps
    end
  end
  
  def self.down
    drop_table :acquisitions
  end
end
