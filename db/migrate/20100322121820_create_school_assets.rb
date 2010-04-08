class CreateSchoolAssets < ActiveRecord::Migration
  def self.up
  #	drop_table :school_assets
  	
    create_table :school_assets do |t|
    t.string :asset_type, :null => false
    t.integer :asset_id, :null => false
    t.integer :school_id, :null => false
    t.integer :view_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :school_assets
  end
end
