class CreateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :suggestions do |t|
      t.string :title
      t.text :message
      t.string :opinion
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :suggestions
  end
end
