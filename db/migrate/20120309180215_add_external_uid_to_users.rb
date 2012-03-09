class AddExternalUidToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :external_uid, :string
    add_index :users, :external_uid
  end

  def self.down
    remove_column :users, :external_uid
  end
end
