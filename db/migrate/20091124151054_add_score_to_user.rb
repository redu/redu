class AddScoreToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :score, :integer, :default => 0
  end

  def self.down
    remove_column :users, :score
  end
end
