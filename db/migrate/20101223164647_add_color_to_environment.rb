class AddColorToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :color, :string
  end

  def self.down
    remove_column :environments, :color
  end
end
