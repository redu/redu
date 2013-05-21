# -*- encoding : utf-8 -*-
class CreatePosts < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :posts
  end
end
