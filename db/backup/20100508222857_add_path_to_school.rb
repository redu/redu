class AddPathToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :path, :string
  end

  def self.down
  end
end
