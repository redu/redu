class RemoveEmail2 < ActiveRecord::Migration
  def self.up
    drop_table :emails
  end

  def self.down
    create_table "emails", :force => true do |t|
      t.string   "from"
      t.string   "to"
      t.integer  "last_send_attempt", :default => 0
      t.text     "mail"
      t.datetime "created_on"
    end
  end
end
