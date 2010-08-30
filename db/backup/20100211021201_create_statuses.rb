class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :text
      t.references :in_response_to, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end
