class AddSchoolIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :school_id, :integer
  end

  def self.down
    remove_column :events, :school_id
  end
end
