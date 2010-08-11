class AddStateToBulletin < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :state, :string
  end

  def self.down
    remove_column :bulletins, :state
  end
end
