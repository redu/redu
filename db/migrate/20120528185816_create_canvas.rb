# -*- encoding : utf-8 -*-
class CreateCanvas < ActiveRecord::Migration
  def self.up
    create_table :canvas do |t|
      t.references :user
      t.references :client_application
      t.references :container, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :canvas
  end
end
