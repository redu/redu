class CreateAccessKeys < ActiveRecord::Migration
  def self.up
    create_table :access_keys do |t|
      t.string :key
      t.date :expiration_date
     # t.integer :user_id
     # t.integer :school_id
      t.timestamps
    end
  end

  def self.down
    drop_table :access_keys
  end
end
