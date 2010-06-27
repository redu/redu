class CreateBetaCandidates < ActiveRecord::Migration
  def self.up
    create_table :beta_candidates do |t|
      t.string :name
      t.string :email
      t.boolean :role
      t.boolean :invited

      t.timestamps
    end
  end

  def self.down
    drop_table :beta_candidates
  end
end
