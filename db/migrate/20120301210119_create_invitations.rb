class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.string :invitable_type
      t.integer :invitable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
