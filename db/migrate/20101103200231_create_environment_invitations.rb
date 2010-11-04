class CreateEnvironmentInvitations < ActiveRecord::Migration
  def self.up
    create_table :environment_invitations do |t|
      t.integer :environment_id
      t.string :email
      t.string :state
      t.datetime :created_at
      t.datetime :updated_at
      t.text :message
      t.integer :user_id
      t.integer :role_id
    end
  end

  def self.down
    drop_table :environment_invitations
  end
end
