# -*- encoding : utf-8 -*-
class RemoveBackgroundrb < ActiveRecord::Migration
  def self.up
    drop_table :bdrb_job_queues
  end

  def self.down
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
  end
end
