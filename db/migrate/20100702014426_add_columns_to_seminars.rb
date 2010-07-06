class AddColumnsToSeminars < ActiveRecord::Migration
  def self.up
    add_column :seminars, :state, :string
    add_column :seminars, :published, :boolean, :default => false
    add_column :seminars, :public, :boolean, :default => false
  end

  def self.down
  end
end
