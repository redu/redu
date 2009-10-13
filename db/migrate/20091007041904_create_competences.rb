class CreateCompetences < ActiveRecord::Migration
  def self.up
    create_table :competences do |t|
      t.string :name
     # t.double :value

      t.timestamps
    end
  end

  def self.down
    drop_table :competences
  end
end
