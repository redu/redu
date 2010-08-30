class AddMembersCounterToSchool < ActiveRecord::Migration
  def self.up
    add_column :schools, :members_count, :integer, :default => 0
  end

  def self.down
    remove_column :schools, :members_count
  end
end
