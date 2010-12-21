class AddStateToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :state, :string
  end

  def self.down
    remove_column :invitations, :state
  end
end
