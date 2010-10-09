class CreateAttrsPolyInBullentin < ActiveRecord::Migration
  def self.up
    remove_column :bulletins, :school_id
    add_column :bulletins, :bulletinable_id, :integer
    add_column :bulletins, :bulletinable_type, :string
  end

  def self.down
    add_column :bulletins, :school_id, :integer
    remove_column :bulletins, :bulletinable_id
    remove_column :bulletins, :bulletinable_type
  end
end
