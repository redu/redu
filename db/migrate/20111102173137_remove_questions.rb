# -*- encoding : utf-8 -*-
class RemoveQuestions < ActiveRecord::Migration
  def self.up
    drop_table :questions
  end

  def self.down
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
  end
end
