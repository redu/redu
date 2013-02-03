class AddCurrentUrlToCanvas < ActiveRecord::Migration
  def self.up
    add_column :canvas, :url, :string
  end

  def self.down
    remove_column :canvas, :url
  end
end
