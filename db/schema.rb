# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100810152117) do

  create_table "abilities", :force => true do |t|
    t.string   "name"
    t.float    "value"
    t.float    "weight"
    t.integer  "competence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "access_keys", :force => true do |t|
    t.string   "key"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  create_table "acquisitions", :force => true do |t|
    t.integer  "course_id"
    t.integer  "acquired_by_id"
    t.string   "acquired_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "value",            :precision => 8, :scale => 2, :default => 0.0
  end

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "action",     :limit => 50
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
  end

  add_index "activities", ["created_at"], :name => "index_activities_on_created_at"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "ads", :force => true do |t|
    t.string   "name"
    t.text     "html"
    t.integer  "frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "location"
    t.boolean  "published",        :default => false
    t.boolean  "time_constrained", :default => false
    t.string   "audience",         :default => "all"
  end

  create_table "albums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "view_count"
  end

  create_table "alternatives", :force => true do |t|
    t.string   "statement",   :null => false
    t.integer  "question_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annotations", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "course_id",  :null => false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets", :force => true do |t|
    t.string   "filename"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.integer  "size"
    t.string   "attachable_type"
    t.integer  "attachable_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.string   "thumbnail"
    t.integer  "parent_id"
  end

  create_table "audiences", :force => true do |t|
    t.string "name"
  end

  create_table "audiences_schools", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "school_id"
  end

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "beta_candidates", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "role"
    t.boolean  "invited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "beta_keys", :force => true do |t|
    t.string  "key"
    t.integer "user_id"
    t.string  "email"
  end

  create_table "bulletins", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
    t.text   "tips"
    t.string "new_post_text"
    t.string "nav_text"
  end

  create_table "choices", :force => true do |t|
    t.integer "poll_id"
    t.string  "description"
    t.integer "votes_count", :default => 0
  end

  create_table "clippings", :force => true do |t|
    t.string   "url"
    t.integer  "user_id"
    t.string   "image_url"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clippings", ["created_at"], :name => "index_clippings_on_created_at"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.datetime "created_at",                                       :null => false
    t.integer  "commentable_id",                 :default => 0,    :null => false
    t.string   "commentable_type", :limit => 15, :default => "",   :null => false
    t.integer  "user_id",                        :default => 0,    :null => false
    t.integer  "recipient_id"
    t.text     "comment"
    t.string   "author_name"
    t.string   "author_email"
    t.string   "author_url"
    t.string   "author_ip"
    t.boolean  "notify_by_email",                :default => true
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["recipient_id"], :name => "index_comments_on_recipient_id"
  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "comments_courses", :id => false, :force => true do |t|
    t.integer "comment_id"
    t.integer "course_id"
  end

  create_table "contests", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "begin_date"
    t.datetime "end_date"
    t.text     "raw_post"
    t.text     "post"
    t.string   "banner_title"
    t.string   "banner_subtitle"
  end

  create_table "countries", :force => true do |t|
    t.string "name"
  end

  create_table "course_resources", :force => true do |t|
    t.string   "name"
    t.string   "attachment_file_name"
    t.integer  "attachment_file_size"
    t.string   "attachment_content_type"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attachable_id"
    t.string   "attachable_type"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_average",     :limit => 10, :precision => 10, :scale => 0, :default => 0
    t.integer  "owner",                                                                              :null => false
    t.text     "description",                                                                        :null => false
    t.boolean  "published",                                                       :default => false
    t.datetime "media_updated_at"
    t.string   "state"
    t.integer  "view_count",                                                      :default => 0
    t.boolean  "public",                                                          :default => true
    t.decimal  "price",                            :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "removed",                                                         :default => false
    t.string   "courseable_type"
    t.integer  "courseable_id"
    t.integer  "simple_category_id"
  end

  create_table "credits", :force => true do |t|
    t.decimal  "value",         :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "payment_type"
    t.integer  "customer_id"
    t.string   "customer_type"
  end

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "description"
    t.integer  "metro_area_id"
    t.string   "location"
  end

  create_table "exam_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "exam_id"
    t.datetime "done_at"
    t.integer  "correct_count", :default => 0
    t.boolean  "public",        :default => false
    t.integer  "time"
  end

  create_table "exams", :force => true do |t|
    t.integer  "owner_id",                                                            :null => false
    t.string   "name",                                                                :null => false
    t.text     "description"
    t.boolean  "published",                                        :default => false
    t.integer  "done_count",                                       :default => 0
    t.float    "total_correct",                                    :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.integer  "level",                                            :default => 2
    t.decimal  "price",              :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "public",                                           :default => true
    t.boolean  "removed",                                          :default => false
    t.integer  "simple_category_id"
    t.string   "state"
  end

  create_table "external_objects", :force => true do |t|
    t.text     "html_embed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "favoritable_id"
    t.string   "favoritable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.datetime "date_modified"
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "school_id"
  end

  create_table "followship", :id => false, :force => true do |t|
    t.integer "followed_by_id"
    t.integer "follows_id"
  end

  create_table "forums", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "topics_count",     :default => 0
    t.integer "sb_posts_count",   :default => 0
    t.integer "position"
    t.text    "description_html"
    t.string  "owner_type"
    t.integer "owner_id"
    t.integer "school_id",                       :null => false
  end

  create_table "friendship_statuses", :force => true do |t|
    t.string "name"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "friend_id"
    t.integer  "user_id"
    t.boolean  "initiator",            :default => false
    t.datetime "created_at"
    t.integer  "friendship_status_id"
  end

  add_index "friendships", ["friendship_status_id"], :name => "index_friendships_on_friendship_status_id"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "group_permissions", :force => true do |t|
    t.integer "folder_id"
    t.integer "group_id"
    t.integer "school_id"
    t.boolean "can_create", :default => false
    t.boolean "can_read",   :default => false
    t.boolean "can_update", :default => false
    t.boolean "can_delete", :default => false
  end

  create_table "groups", :force => true do |t|
    t.string  "name"
    t.boolean "is_the_administrators_group", :default => false
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "homepage_features", :force => true do |t|
    t.datetime "created_at"
    t.string   "url"
    t.string   "title"
    t.text     "description"
    t.datetime "updated_at"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "images", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interactive_classes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.string   "email_addresses"
    t.string   "message"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  create_table "lessons", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "interactive_class_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lesson_type"
    t.integer  "lesson_id"
  end

  create_table "logs", :force => true do |t|
    t.string   "logeable_type"
    t.string   "action"
    t.integer  "user_id"
    t.string   "logeable_name"
    t.integer  "logeable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.string   "subject"
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metro_areas", :force => true do |t|
    t.string  "name"
    t.integer "state_id"
    t.integer "country_id"
    t.integer "users_count", :default => 0
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

  create_table "myfiles", :force => true do |t|
    t.integer  "folder_id"
    t.integer  "user_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "offerings", :force => true do |t|
    t.integer "skill_id"
    t.integer "user_id"
  end

  create_table "pages", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "width"
    t.integer  "height"
    t.integer  "album_id"
    t.integer  "view_count"
  end

  add_index "photos", ["created_at"], :name => "index_photos_on_created_at"
  add_index "photos", ["parent_id"], :name => "index_photos_on_parent_id"

  create_table "plugin_schema_migrations", :id => false, :force => true do |t|
    t.string "plugin_name"
    t.string "version"
  end

  create_table "polls", :force => true do |t|
    t.string   "question"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "post_id"
    t.integer  "votes_count", :default => 0
  end

  add_index "polls", ["created_at"], :name => "index_polls_on_created_at"
  add_index "polls", ["post_id"], :name => "index_polls_on_post_id"

  create_table "posts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "raw_post"
    t.text     "post"
    t.string   "title"
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "view_count",                  :default => 0
    t.integer  "contest_id"
    t.integer  "emailed_count",               :default => 0
    t.string   "published_as",  :limit => 16, :default => "draft"
    t.datetime "published_at"
  end

  add_index "posts", ["category_id"], :name => "index_posts_on_category_id"
  add_index "posts", ["published_as"], :name => "index_posts_on_published_as"
  add_index "posts", ["published_at"], :name => "index_posts_on_published_at"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.string   "occupation"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_exam_associations", :id => false, :force => true do |t|
    t.integer  "total_answers_count"
    t.integer  "correct_answers_count"
    t.integer  "question_id"
    t.integer  "exam_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.text     "statement",                            :null => false
    t.integer  "answer_id"
    t.integer  "author_id"
    t.boolean  "public",            :default => false
    t.text     "justification"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "subcategory_id"
    t.integer  "subsubcategory_id"
  end

  create_table "rates", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars"
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id"], :name => "index_rates_on_rateable_id"
  add_index "rates", ["user_id"], :name => "index_rates_on_user_id"

  create_table "redu_categories", :force => true do |t|
    t.string "name"
  end

  create_table "redu_categories_schools", :id => false, :force => true do |t|
    t.integer "redu_category_id"
    t.integer "school_id"
  end

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.boolean "school_role", :null => false
  end

  create_table "rsvps", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "attendees_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sb_posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.text     "body_html"
  end

  add_index "sb_posts", ["forum_id", "created_at"], :name => "index_sb_posts_on_forum_id"
  add_index "sb_posts", ["user_id", "created_at"], :name => "index_sb_posts_on_user_id"

  create_table "school_assets", :force => true do |t|
    t.string   "asset_type",                :null => false
    t.integer  "asset_id",                  :null => false
    t.integer  "school_id",                 :null => false
    t.integer  "view_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "key_price",           :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner",                                                                    :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "public_profile",                                    :default => true
    t.integer  "submission_type",                                   :default => 1
    t.integer  "subscription_type"
    t.string   "path"
    t.string   "theme",                                             :default => "default"
    t.boolean  "removed",                                           :default => false
    t.boolean  "public",                                            :default => true
    t.integer  "courses_count",                                     :default => 0
    t.integer  "members_count",                                     :default => 0
  end

  create_table "seminars", :force => true do |t|
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.time     "media_updated_at"
    t.string   "external_resource"
    t.string   "external_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.boolean  "published",              :default => false
    t.boolean  "public",                 :default => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "sessid"
    t.text     "data"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "sessions", ["sessid"], :name => "index_sessions_on_sessid"

  create_table "simple_categories", :force => true do |t|
    t.string "name"
  end

  create_table "skills", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
  end

  create_table "states", :force => true do |t|
    t.string "name"
  end

  create_table "statuses", :force => true do |t|
    t.string   "text"
    t.integer  "in_response_to_id"
    t.string   "in_response_to_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind"
    t.integer  "user_id"
  end

  create_table "suggestions", :force => true do |t|
    t.string   "title"
    t.text     "message"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "yes"
    t.integer  "no"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"
  add_index "taggings", ["taggable_type"], :name => "index_taggings_on_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

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
  end

  add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"
  add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"

  create_table "user_competences", :force => true do |t|
    t.integer  "user_id",                      :null => false
    t.integer  "skill_id",                     :null => false
    t.integer  "done_count",    :default => 0
    t.integer  "correct_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_course_associations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_school_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "school_id"
    t.integer  "role_id",       :default => 7
    t.integer  "access_key_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.text     "description"
    t.integer  "avatar_id"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.text     "stylesheet"
    t.integer  "view_count",                           :default => 0
    t.boolean  "vendor",                               :default => false
    t.string   "activation_code",        :limit => 40
    t.datetime "activated_at"
    t.integer  "state_id"
    t.integer  "metro_area_id"
    t.string   "login_slug"
    t.boolean  "notify_comments",                      :default => true
    t.boolean  "notify_friend_requests",               :default => true
    t.boolean  "notify_community_news",                :default => true
    t.integer  "country_id"
    t.boolean  "featured_writer",                      :default => false
    t.datetime "last_login_at"
    t.string   "zip"
    t.date     "birthday"
    t.string   "gender"
    t.boolean  "profile_public",                       :default => true
    t.integer  "activities_count",                     :default => 0
    t.integer  "sb_posts_count",                       :default => 0
    t.datetime "sb_last_seen_at"
    t.integer  "role_id"
    t.integer  "followers_count",                      :default => 0
    t.integer  "follows_count",                        :default => 0
    t.integer  "score",                                :default => 0
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "my_activity",                          :default => true
    t.boolean  "removed",                              :default => false
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                          :default => 0
    t.integer  "failed_login_count",                   :default => 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "oauth_token"
    t.string   "oauth_secret"
  end

  add_index "users", ["activated_at"], :name => "index_users_on_activated_at"
  add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["featured_writer"], :name => "index_users_on_featured_writer"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["login_slug"], :name => "index_users_on_login_slug"
  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "users", ["vendor"], :name => "index_users_on_vendor"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"

end
