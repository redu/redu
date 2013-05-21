# -*- encoding : utf-8 -*-
class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.references :user
      t.references :exercise
      t.timestamp :started_at
      t.timestamp :finalized_at
      t.string :state
      t.decimal :grade, :precision => 4, :scale => 2,
        :default => BigDecimal.new("0.0")
      t.integer :duration, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
