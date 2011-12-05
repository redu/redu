class CreateNotifiables < ActiveRecord::Migration
  def self.up
    create_table :notifiables do |t|
      t.string     "name"
      t.integer    "counter"
      t.integer    "user_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :notifiables
  end
end
