class RefactorLog < ActiveRecord::Migration
  def self.up
    
    remove_column :logs, :actor_name
    remove_column :logs, :comment
    rename_column(:logs, :actor_id, :user_id)
    rename_column(:logs, :table, :logeable_type )
    rename_column(:logs, :object_name, :logeable_name )
    rename_column(:logs, :object_id, :logeable_id )
  end

  def self.down
  end
end
