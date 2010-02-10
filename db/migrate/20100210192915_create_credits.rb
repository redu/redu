class CreateCredits < ActiveRecord::Migration
  def self.up
    create_table :credits do |t|
      t.decimal :value, :precision => 8, :scale => 2, :default => 0
      t.integer :user_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :credits
  end
end
