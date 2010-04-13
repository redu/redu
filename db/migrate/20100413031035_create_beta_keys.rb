class CreateBetaKeys < ActiveRecord::Migration
  def self.up
    create_table :beta_keys do |t|
      t.string :key
    end
    
    add_column :users, :beta_key_id, :integer
    
    BetaKey.create({:key => 'abcdef'})
  end

  def self.down
    drop_table :beta_keys
    remove_column :users, :beta_key_id
  end
end
