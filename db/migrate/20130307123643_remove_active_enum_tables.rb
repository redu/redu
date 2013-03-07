class RemoveActiveEnumTables < ActiveRecord::Migration
  def self.up
    drop_table :roles
    drop_table :privacies
  end

  def self.down
    create_table "privacies", :force => true do |t|
      t.string "name"
    end

    create_table "roles", :force => true do |t|
      t.string  "name"
      t.boolean "space_role", :null => false
    end
  end
end
