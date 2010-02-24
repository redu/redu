class AddPublishedToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :published, :boolean, {:default => true}
  end

  def self.down
    remove_column :resources, :published
  end
end


