class AddSkillIdQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :skill_id, :integer
  end

  def self.down
    remove_column :questions, :skill_id
  end
end
