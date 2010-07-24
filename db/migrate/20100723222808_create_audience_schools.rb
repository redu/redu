class CreateAudienceSchools < ActiveRecord::Migration
  def self.up
    create_table :audiences_schools, :id => false do |t|
       t.integer :audience_id
       t.integer :school_id
      #t.timestamps
    end
  end

  def self.down
    drop_table :audiences_schools
  end
end
