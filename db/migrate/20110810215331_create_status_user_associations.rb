class CreateStatusUserAssociations < ActiveRecord::Migration
  def self.up
    create_table :status_user_associations do |t|
      t.references :status
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :status_user_associations
  end
end
