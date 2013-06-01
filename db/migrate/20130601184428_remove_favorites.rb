class RemoveFavorites < ActiveRecord::Migration
  def up
    drop_table :favorites
  end

  def down
    create_table "favorites", :force => true do |t|
      t.integer  "favoritable_id"
      t.string   "favoritable_type"
      t.integer  "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
