class AddPublicToSchools < ActiveRecord::Migration
  def self.up
    add_column :schools, :public, :boolean, :default => true
  end

  def self.down
    remove_column :schools, :public
  end
end
