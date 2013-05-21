# -*- encoding : utf-8 -*-
class RenameSessionIdColumn < ActiveRecord::Migration
  def change
    remove_index :sessions, :sessid
    rename_column :sessions, :sessid, :session_id
    add_index :sessions, :session_id
  end
end
