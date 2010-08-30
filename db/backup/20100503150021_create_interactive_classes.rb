class CreateInteractiveClasses < ActiveRecord::Migration
  def self.up
    create_table :interactive_classes do |t|
      t.string :name
      t.string :tagline
      t.text :description
      


      t.timestamps
    end
  end

  def self.down
    drop_table :interactive_classes
  end
end
