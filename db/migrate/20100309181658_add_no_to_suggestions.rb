class AddNoToSuggestions < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :no, :integer
  end

  def self.down
    remove_column :suggestions, :no
  end
end
