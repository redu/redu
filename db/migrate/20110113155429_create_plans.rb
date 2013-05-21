# -*- encoding : utf-8 -*-
class CreatePlans < ActiveRecord::Migration
  def self.up
    create_table :plans do |t|
      t.string :state
      t.string :name
      t.integer :video_storage_limit
      t.integer :members_limit
      t.integer :file_storage_limit
      t.decimal :price, :precision => 8, :scale => 2
      t.references :plan
      t.references :user
      t.belongs_to :billable, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :plans
  end
end
