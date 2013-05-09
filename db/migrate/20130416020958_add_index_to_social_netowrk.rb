class AddIndexToSocialNetowrk < ActiveRecord::Migration
  def self.up
    add_index :social_networks, :user_id
  end

  def self.down
    remove_index :social_networks, :user_id
  end
end
