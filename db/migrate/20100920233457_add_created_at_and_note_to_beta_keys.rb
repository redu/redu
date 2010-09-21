class AddCreatedAtAndNoteToBetaKeys < ActiveRecord::Migration
  def self.up
    add_column :beta_keys, :created_at, :datetime
    add_column :beta_keys, :note, :text
  end

  def self.down
    remove_column :beta_keys, :created_at
    remove_column :beta_keys, :note
  end
end
