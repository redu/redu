# -*- encoding : utf-8 -*-
class AllMigrations < ActiveRecord::Migration
  def self.up


  create_table "acquisitions", :force => true do |t|
    t.integer  "course_id"
    t.integer  "acquired_by_id"
    t.string   "acquired_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "value",            :precision => 8, :scale => 2, :default => 0.0
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

  create_table "bulletins", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id"
    t.string   "state"
    t.integer  "owner"
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
    t.integer  "rating_average",      :limit => 10, :precision => 10, :scale => 0, :default => 0
    t.integer  "owner",                                                                               :null => false
    t.text     "description",                                                                         :null => false
    t.boolean  "published",                                                        :default => false
    t.datetime "media_updated_at"
    t.string   "state"
    t.integer  "view_count",                                                       :default => 0
    t.boolean  "public",                                                           :default => true
    t.decimal  "price",                             :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "removed",                                                          :default => false
    t.string   "courseable_type"
    t.integer  "courseable_id"
    t.integer  "simple_category_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
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
    t.integer  "owner"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "description"
    t.string   "location"
    t.string   "state"
    t.integer  "school_id"
    t.boolean  "public",      :default => false
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

  create_table "redu_categories_schools", :id => false, :force => true do |t|
    t.integer "redu_category_id"
    t.integer "school_id"
  end

  create_table "roles", :force => true do |t|
    t.string  "name"
    t.boolean "school_role", :null => false
  end


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
    t.boolean  "published",              :default => false
    t.boolean  "public",                 :default => false
    t.string   "state"
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
    t.string   "activation_code",        :limit => 40
    t.datetime "activated_at"
    t.integer  "state_id"
    t.integer  "metro_area_id"
    t.string   "login_slug"
    t.boolean  "notify_comments",                      :default => true
    t.boolean  "notify_friend_requests",               :default => true
    t.boolean  "notify_community_news",                :default => true
    t.integer  "country_id"
    t.datetime "last_login_at"
    t.string   "zip"
    t.date     "birthday"
    t.string   "gender"
    t.boolean  "profile_public",                       :default => true
    t.integer  "role_id",                              :default => 3
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
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
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

  def self.down
    drop_table :acquisitions
    drop_table :alternatives
    drop_table :annotations
    drop_table :audiences
    drop_table :audiences_schools
    drop_table :bdrb_job_queues
    drop_table :beta_candidates
    drop_table :bulletins
    drop_table :countries
    drop_table :course_resources
    drop_table :courses
    drop_table :credits
    drop_table :delayed_jobs
    drop_table :emails
    drop_table :events
    drop_table :exam_users
    drop_table :exams
    drop_table :favorites
    drop_table :folders
    drop_table :followship
    drop_table :group_permissions
    drop_table :groups
    drop_table :groups_users
    drop_table :messages
    drop_table :metro_areas
    drop_table :myfiles
    drop_table :pages
    drop_table :question_exam_associations
    drop_table :questions
    drop_table :rates
    drop_table :redu_categories_schools
    drop_table :roles
    drop_table :school_assets
    drop_table :schools
    drop_table :seminars
    drop_table :sessions
    drop_table :simple_categories
    drop_table :states
    drop_table :statuses
    drop_table :taggings
    drop_table :tags
    drop_table :users
    drop_table :user_school_associations
    drop_table :votes
  end
end
