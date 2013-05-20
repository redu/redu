# -*- encoding : utf-8 -*-
class CreateStatusUserAssociations < ActiveRecord::Migration
  def self.up
    create_table :status_user_associations do |t|
      t.references :user
      t.references :status
      t.timestamps
    end

    add_index :status_user_associations, [:user_id]
  end

  def self.down
    remove_index :status_user_associations, [:user_id]
    drop_table :status_user_associations
  end
end
