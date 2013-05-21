# -*- encoding : utf-8 -*-
class RemovePosts < ActiveRecord::Migration
  def self.up
    drop_table :posts
  end

  def self.down
    create_table :posts do |t|
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "raw_post", :text
      t.column "post", :text
      t.column "title", :string
      t.column "category_id", :integer
      t.column "user_id", :integer
      t.column "view_count", :integer, :default => 0
      t.column "published_as", :string, :limit => 16, :default => 'draft'
      t.column "published_at", :datetime
    end 
  end
end
