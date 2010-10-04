class AddLastSentAtToBetaKeys < ActiveRecord::Migration
  def self.up
    add_column :beta_keys, :last_sent_at, :datetime
  end

  def self.down
    remove_column :beta_keys, :last_sent_at
  end
end
