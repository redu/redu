# -*- encoding : utf-8 -*-
class CreateUserEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    create_table :user_environment_associations do |t|
      t.integer :user_id
      t.integer :environment_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_environment_associations
  end
end
