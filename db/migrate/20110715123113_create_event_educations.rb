# -*- encoding : utf-8 -*-
class CreateEventEducations < ActiveRecord::Migration
  def self.up
    create_table :event_educations do |t|
      t.string :name
      t.string :role
      t.date :year

      t.timestamps
    end
  end

  def self.down
    drop_table :event_educations
  end
end
