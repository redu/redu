class CreateBetaKeys < ActiveRecord::Migration
  def self.up
    create_table :beta_keys do |t|
      t.string :key
      t.integer :user_id
    end
    
    
    BetaKey.create({:key => 'abcdef'})
  end

  def self.down
    drop_table :beta_keys
  end
end
