class AddPriceToAcquisition < ActiveRecord::Migration
  def self.up
    add_column :acquisitions, :value, :decimal, :precision => 8, :scale => 2, :default => 0
  end

  def self.down
    remove_column :acquisitions, :value
  end
end
