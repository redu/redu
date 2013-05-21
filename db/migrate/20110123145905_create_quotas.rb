# -*- encoding : utf-8 -*-
class CreateQuotas < ActiveRecord::Migration
  def self.up
    create_table :quotas do |t|
      t.integer :multimedia
      t.integer :files
      t.integer :billable_id
      t.string :billable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :quotas
  end
end
