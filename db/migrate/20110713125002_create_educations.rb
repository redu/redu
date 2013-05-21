# -*- encoding : utf-8 -*-
class CreateEducations < ActiveRecord::Migration
  def self.up
    create_table :educations do |t|
      t.string :educationable_type
      t.integer :educationable_id
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :educations
  end
end
