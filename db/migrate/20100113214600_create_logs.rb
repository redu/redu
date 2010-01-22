class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string :table
      t.string :action
      t.string :actor_name
      t.integer :actor_id
      t.string :object_name
      t.integer :object_id
      t.text :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
