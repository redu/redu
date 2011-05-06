# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110506124509) do

  create_table "acquisitions", :force => true do |t|
    t.integer  "lecture_id"
    t.integer  "acquired_by_id"
    t.string   "acquired_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "value",            :precision => 8, :scale => 2, :default => 0.0
  end

  create_table "alternatives", :force => true do |t|
    t.string   "statement",                      :null => false
    t.integer  "question_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "correct",     :default => false
  end

  create_table "annotations", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "lecture_id",                 :null => false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_name", :default => ""
  end

  create_table "asset_reports", :force => true do |t|
    t.integer "student_profile_id"
    t.boolean "done",               :default => false
    t.integer "subject_id"
    t.integer "lecture_id"
  end

  create_table "audiences", :force => true do |t|
    t.string "name"
  end

  create_table "audiences_courses", :id => false, :force => true do |t|
    t.integer "audience_id"
    t.integer "course_id"
  end

  create_table "beta_candidates", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "role"
    t.boolean  "invited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bulletins", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.integer  "owner"
    t.integer  "bulletinable_id"
    t.string   "bulletinable_type"
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                                 :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 25
    t.string   "guid",              :limit => 10
    t.integer  "locale",            :limit => 1,  :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "fk_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_assetable_type"
  add_index "ckeditor_assets", ["user_id"], :name => "fk_user"

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
    t.text     "description"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "environment_id"
    t.integer  "workload"
    t.integer  "subscription_type", :default => 1
    t.integer  "owner",                               :null => false
    t.boolean  "published",         :default => true
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documents", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "ipaper_id"
    t.string   "ipaper_access_key"
    t.string   "state"
    t.boolean  "published",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
  end

  create_table "enrollments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id",    :default => 7
  end

  create_table "environments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "path"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "theme"
    t.integer  "owner",                                                   :null => false
    t.boolean  "published",                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",                             :default => "34cdf9"
    t.string   "initials",            :limit => 80,                       :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "description"
    t.string   "location"
    t.string   "state"
    t.integer  "eventable_id"
    t.string   "eventable_type"
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
    t.integer  "owner_id",                         :null => false
    t.string   "name",                             :null => false
    t.text     "description"
    t.boolean  "published",     :default => false
    t.integer  "done_count",    :default => 0
    t.float    "total_correct", :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "instruction"
    t.integer  "level",         :default => 2
    t.boolean  "removed",       :default => false
    t.string   "state"
    t.boolean  "is_clone",      :default => false
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
    t.integer  "space_id"
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

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "requested_at"
    t.datetime "accepted_at"
    t.string   "status"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["status"], :name => "index_friendships_on_status"
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "group_permissions", :force => true do |t|
    t.integer "folder_id"
    t.integer "group_id"
    t.integer "space_id"
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

  create_table "invoices", :force => true do |t|
    t.date     "period_start"
    t.date     "period_end"
    t.datetime "due_at"
    t.string   "currency",                                   :default => "BRL"
    t.string   "state"
    t.decimal  "amount",       :precision => 8, :scale => 2
    t.text     "description"
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "discount",     :precision => 8, :scale => 2, :default => 0.0
    t.text     "audit"
  end

  create_table "lectures", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating_average",      :default => 0
    t.integer  "owner",                                  :null => false
    t.text     "description",                            :null => false
    t.boolean  "published",           :default => false
    t.datetime "media_updated_at"
    t.integer  "view_count",          :default => 0
    t.boolean  "removed",             :default => false
    t.string   "lectureable_type"
    t.integer  "lectureable_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "is_clone",            :default => false
    t.integer  "subject_id"
    t.integer  "position"
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

  create_table "pages", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "state"
    t.string   "name"
    t.integer  "video_storage_limit"
    t.integer  "members_limit"
    t.integer  "file_storage_limit"
    t.decimal  "price",               :precision => 8, :scale => 2
    t.integer  "plan_id"
    t.integer  "user_id"
    t.integer  "billable_id"
    t.string   "billable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "billing_date"
    t.decimal  "yearly_price",        :precision => 8, :scale => 2
  end

  create_table "privacies", :force => true do |t|
    t.string "name"
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
    t.string   "source"
  end

  create_table "quotas", :force => true do |t|
    t.integer  "multimedia",    :default => 0
    t.integer  "files",         :default => 0
    t.integer  "billable_id"
    t.string   "billable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rates", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars",         :null => false
    t.string   "dimension"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id", "rateable_type"], :name => "index_rates_on_rateable_id_and_rateable_type"
  add_index "rates", ["rater_id"], :name => "index_rates_on_rater_id"

  create_table "redu_categories", :force => true do |t|
    t.string "name"
  end

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.boolean "space_role", :null => false
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

  create_table "seminars", :force => true do |t|
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.time     "media_updated_at"
    t.string   "external_resource"
    t.string   "external_resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",              :default => false
    t.string   "state"
    t.string   "original_file_name"
    t.string   "original_content_type"
    t.integer  "original_file_size"
    t.datetime "original_updated_at"
    t.integer  "job"
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

  create_table "spaces", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner",                                      :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "submission_type"
    t.string   "theme",               :default => "default"
    t.boolean  "removed",             :default => false
    t.integer  "lectures_count",      :default => 0
    t.integer  "members_count",       :default => 0
    t.integer  "course_id"
    t.boolean  "published",           :default => true
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
    t.integer  "statusable_id",                          :null => false
    t.string   "statusable_type",                        :null => false
    t.boolean  "log",                 :default => false
    t.string   "logeable_type"
    t.integer  "logeable_id"
    t.string   "log_action"
    t.string   "logeable_name"
  end

  create_table "student_profiles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.boolean  "graduaded",     :default => false
    t.float    "grade",         :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "enrollment_id"
  end

  create_table "subjects", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visible",     :default => false
    t.boolean  "finalized",   :default => false
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
    t.integer  "space_id"
  end

  add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"
  add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"

  create_table "user_course_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  create_table "user_course_invitations", :force => true do |t|
    t.string   "token",      :null => false
    t.string   "email",      :null => false
    t.integer  "user_id"
    t.integer  "course_id",  :null => false
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_environment_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  create_table "user_settings", :force => true do |t|
    t.integer "user_id"
    t.integer "view_mural_id"
  end

  create_table "user_space_associations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "space_id"
    t.integer  "role_id",    :default => 7
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
    t.string   "activation_code",         :limit => 40
    t.datetime "activated_at"
    t.integer  "state_id"
    t.integer  "metro_area_id"
    t.string   "login_slug"
    t.boolean  "notify_messages",                       :default => true
    t.boolean  "notify_followships",                    :default => true
    t.boolean  "notify_community_news",                 :default => true
    t.integer  "country_id"
    t.datetime "last_login_at"
    t.string   "zip"
    t.date     "birthday"
    t.string   "gender"
    t.boolean  "profile_public",                        :default => true
    t.integer  "role",                                  :default => 2
    t.integer  "score",                                 :default => 0
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "my_activity",                           :default => true
    t.boolean  "removed",                               :default => false
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                           :default => 0
    t.integer  "failed_login_count",                    :default => 0
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "auto_status",                           :default => true
    t.boolean  "has_invited",                           :default => false
    t.boolean  "teacher_profile",                       :default => false
    t.integer  "sb_posts_count",                        :default => 0
    t.datetime "sb_last_seen_at"
    t.string   "curriculum_file_name"
    t.string   "curriculum_content_type"
    t.integer  "curriculum_file_size"
    t.datetime "curriculum_updated_at"
    t.integer  "friends_count",                         :default => 0,     :null => false
    t.string   "mobile"
    t.string   "localization"
  end

  add_index "users", ["activated_at"], :name => "index_users_on_activated_at"
  add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"
  add_index "users", ["created_at"], :name => "index_users_on_created_at"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["login_slug"], :name => "index_users_on_login_slug"
  add_index "users", ["oauth_token"], :name => "index_users_on_oauth_token"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

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
