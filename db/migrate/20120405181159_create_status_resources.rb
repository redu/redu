class CreateStatusResources < ActiveRecord::Migration
  def self.up
    create_table :status_resources do |t|
      t.string :provider
      t.string :type
      t.string :thumb_url
      t.string :title
      t.string :description
      t.string :link
      t.integer :status_id

      t.timestamps
    end
  end

  def self.down
    drop_table :status_resources
  end
end
