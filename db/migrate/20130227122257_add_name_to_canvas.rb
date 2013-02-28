class AddNameToCanvas < ActiveRecord::Migration
  def self.up
    add_column :canvas, :name, :string
  end

  def self.down
    remove_column :canvas, :name
  end
end
