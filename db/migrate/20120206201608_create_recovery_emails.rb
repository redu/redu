class CreateRecoveryEmails < ActiveRecord::Migration
  def self.up
    create_table :recovery_emails do |t|
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :recovery_emails
  end
end
