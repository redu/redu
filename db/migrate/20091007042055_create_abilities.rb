class CreateAbilities < ActiveRecord::Migration
  def self.up
    create_table :abilities do |t|
      t.string :name
      t.float :value
      t.float :weight
      t.integer :competence_id

      t.timestamps
    end
  end

  def self.down
    drop_table :abilities
  end
end
