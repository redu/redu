class AddStatusToUserSchoolAssociation < ActiveRecord::Migration
  def self.up
    add_column :user_school_associations, :status, :string
  end

  def self.down
  end
end
