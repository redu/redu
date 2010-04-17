class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.string :name, :null => false
      t.text :description   
      t.string :state
      t.integer :owner, :null => false
      #t.references :resourceable, :polymorphic => true 
      t.timestamps
    end
  end

  def self.down
    drop_table :resources
  end
end
