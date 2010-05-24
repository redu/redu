class AddPublicFieldToCourse < ActiveRecord::Migration
  def self.up
     add_column(:courses, :public, :boolean, {:default => true})
  end

  def self.down
  end
end
