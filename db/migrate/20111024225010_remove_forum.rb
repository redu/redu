# -*- encoding : utf-8 -*-
class RemoveForum < ActiveRecord::Migration
  def self.up
    drop_table :forums
    drop_table :moderatorships
    drop_table :monitorships
    drop_table :sb_posts
    drop_table :topics

    remove_column :users, :sb_last_seen_at
    remove_column :users, :sb_posts_count
  end

  def self.down
    change_table :users do |t|
      t.integer  "sb_posts_count",                      :default => 0
      t.datetime "sb_last_seen_at"
    end

    create_table "forums", :force => true do |t|
      t.string  "name"
      t.string  "description"
      t.integer "topics_count",     :default => 0
      t.integer "sb_posts_count",   :default => 0
      t.integer "position"
      t.text    "description_html"
      t.integer "space_id"
    end

    create_table "moderatorships", :force => true do |t|
      t.integer "forum_id"
      t.integer "user_id"
    end

    add_index "moderatorships", ["forum_id"], :name => "index_moderatorships_on_forum_id"

    create_table "monitorships", :force => true do |t|
      t.integer "topic_id"
      t.integer "user_id"
      t.boolean "active",   :default => true
    end

    create_table "sb_posts", :force => true do |t|
      t.integer  "user_id"
      t.integer  "topic_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "forum_id"
      t.text     "body_html"
      t.integer  "space_id"
    end

    add_index "sb_posts", ["forum_id", "created_at"], :name => "index_sb_posts_on_forum_id"
    add_index "sb_posts", ["user_id", "created_at"], :name => "index_sb_posts_on_user_id"

    create_table "topics", :force => true do |t|
      t.integer  "forum_id"
      t.integer  "user_id"
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "hits",           :default => 0
      t.integer  "sticky",         :default => 0
      t.integer  "sb_posts_count", :default => 0
      t.datetime "replied_at"
      t.boolean  "locked",         :default => false
      t.integer  "replied_by"
      t.integer  "last_post_id"
      t.integer  "space_id"
    end

    add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"
    add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
    add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
  end
end
