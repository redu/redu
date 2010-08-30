class AddYesToSuggestions < ActiveRecord::Migration
  def self.up
    add_column :suggestions, :yes, :integer
  end

  def self.down
    remove_column :suggestions, :yes
  end
end
