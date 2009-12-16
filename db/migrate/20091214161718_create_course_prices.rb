class CreateCoursePrices < ActiveRecord::Migration
  
   def self.up
    create_table :course_prices do |t|
      t.integer :course_id
      t.integer :key_number
      t.decimal :price, :precision => 8, :scale => 2, :default => 0
      t.timestamps
    end
    
    add_index(:course_prices, [:course_id, :key_number, :price], :unique => true)
  end
  
  def self.down
    drop_table :course_prices
  end
end
