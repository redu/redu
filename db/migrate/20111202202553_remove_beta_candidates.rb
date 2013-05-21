# -*- encoding : utf-8 -*-
class RemoveBetaCandidates < ActiveRecord::Migration
  def self.up
    drop_table :beta_candidates
  end

  def self.down
    create_table "beta_candidates", :force => true do |t|
      t.string   "name"
      t.string   "email"
      t.boolean  "role"
      t.boolean  "invited"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
