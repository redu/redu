class CreateFavorites < ActiveRecord::Migration
  def self.up
    drop_table :favorites
    create_table :favorites do |t|
      t.string :favorite_type
      t.integer :favorite_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :favorites
  end
end
