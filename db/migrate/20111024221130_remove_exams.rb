# -*- encoding : utf-8 -*-
class RemoveExams < ActiveRecord::Migration
  def self.up
    drop_table :exams
    drop_table :exam_users
    drop_table :question_exam_associations
    drop_table :alternatives
  end

  def self.down
    create_table "alternatives", :force => true do |t|
      t.string   "statement",                      :null => false
      t.integer  "question_id",                    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "correct",     :default => false
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

  end
end
