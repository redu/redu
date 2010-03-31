class RemoveOpinionFromSuggestions < ActiveRecord::Migration
  def self.up
    remove_column :suggestions, :opinion
  end

  def self.down
    add_column :suggestions, :opinion, :string
  end
end
