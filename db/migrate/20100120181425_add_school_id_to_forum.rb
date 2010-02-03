class AddSchoolIdToForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :school_id, :integer, :null => false
  end

  def self.down
    remove_column :forums, :school_id
  end
end
