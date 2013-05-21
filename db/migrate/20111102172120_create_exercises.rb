# -*- encoding : utf-8 -*-
class CreateExercises < ActiveRecord::Migration
  def self.up
    create_table :exercises do |t|
      t.decimal :maximum_grade, :default => BigDecimal.new('10.00'),
        :scale => 2, :precision => 4

      t.timestamps
    end
  end

  def self.down
    drop_table :exercises
  end
end
