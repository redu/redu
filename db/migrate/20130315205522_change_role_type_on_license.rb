class ChangeRoleTypeOnLicense < ActiveRecord::Migration
  def self.up
    change_column :licenses, :role, :string
  end

  def self.down
    change_column :licenses, :role, :integer
  end
end
