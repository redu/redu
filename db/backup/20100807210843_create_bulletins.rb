class CreateBulletins < ActiveRecord::Migration
  def self.up
    create_table :bulletins do |t|
      t.string :title, :null => :false
      t.text :description, :null => :false

      t.timestamps
    end
  end

  def self.down
    drop_table :bulletins
  end
end
