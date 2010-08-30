class AddEmailToBetaKeys < ActiveRecord::Migration
  def self.up
    add_column :beta_keys, :email, :string
  end

  def self.down
  end
end
