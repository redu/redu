class AddPolymorphismToStatuses < ActiveRecord::Migration
  def self.up
     add_column :statuses, :statusable_id, :integer, :null => false
      add_column :statuses, :statusable_type, :string, :null => false
  end

  def self.down
  end
end
