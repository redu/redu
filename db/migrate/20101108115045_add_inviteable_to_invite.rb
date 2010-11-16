class AddInviteableToInvite < ActiveRecord::Migration
  def self.up
    add_column :invitations, :inviteable_type, :string
    add_column :invitations, :inviteable_id, :integer
  end

  def self.down
    remove_column :invitations, :inviteable_type
    remove_column :invitations, :inviteable_id
  end
end
