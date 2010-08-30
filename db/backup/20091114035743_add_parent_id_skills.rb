class AddParentIdSkills < ActiveRecord::Migration
  def self.up
    add_column :skills, :parent_id, :integer
  end

  def self.down
    remove_column :skills, :parent_id
  end
end
