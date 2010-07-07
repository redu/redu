class AddThemeToSchools < ActiveRecord::Migration
  def self.up
    add_column :schools, :theme, :string, :default => 'default'
  end

  def self.down
    remove_column :schools, :theme
  end
end
