# -*- encoding : utf-8 -*-
class ChangeVisibleDefaultFromSubjects < ActiveRecord::Migration
  def self.up
    change_column_default :subjects, :visible, true
  end

  def self.down
    change_column_default :subjects, :visible, false
  end
end
