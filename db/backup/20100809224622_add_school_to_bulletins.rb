class AddSchoolToBulletins < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :school_id, :integer
  end

  def self.down
    remove_column :bulletins, :school_id
  end
end
