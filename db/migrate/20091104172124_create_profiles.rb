class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :user_id, :null => false
      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.string :occupation
      t.text :description 

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
