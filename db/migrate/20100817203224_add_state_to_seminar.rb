class AddStateToSeminar < ActiveRecord::Migration
  def self.up
    add_column :seminars, :state, :string
  end

  def self.down
    remove_column :seminars, :state
  end
end
