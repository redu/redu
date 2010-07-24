class CreateExternalObjects < ActiveRecord::Migration
  def self.up
    create_table :external_objects do |t|
      t.text :html_embed
      t.timestamps
    end
  end

  def self.down
    drop_table :external_objects
  end
end
