class AddWalledgardenFlatToClientApplication < ActiveRecord::Migration
  def self.up
    add_column :client_applications, :walledgarden, :boolean, :default => false
    add_index :client_applications, [:walledgarden, :id]
  end

  def self.down
    remove_column :client_applications, :walledgarden
  end
end
