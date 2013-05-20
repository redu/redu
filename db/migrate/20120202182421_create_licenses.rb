# -*- encoding : utf-8 -*-
class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.string :name
      t.string :login
      t.string :email
      t.date :period_start
      t.date :period_end
      t.integer :role
      t.references :invoice
      t.references :course

      t.timestamps
    end
  end

  def self.down
    drop_table :licenses
  end
end
