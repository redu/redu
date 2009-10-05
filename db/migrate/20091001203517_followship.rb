class Followship < ActiveRecord::Migration
  def self.up
    create_table :followship, :id => false do |t|
      t.references :followed_by, :follows
      end
  end

  def self.down
    drop_table :followship
  end
end
