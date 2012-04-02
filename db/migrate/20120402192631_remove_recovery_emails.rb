class RemoveRecoveryEmails < ActiveRecord::Migration
  def self.up
    drop_table :recovery_emails
  end

  def self.down
    create_table :recovery_emails do |t|
      t.string :email

      t.timestamps
    end
  end
end
