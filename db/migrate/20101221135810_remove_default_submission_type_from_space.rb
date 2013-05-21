# -*- encoding : utf-8 -*-
class RemoveDefaultSubmissionTypeFromSpace < ActiveRecord::Migration
  def self.up
    change_column_default :spaces, :submission_type, nil
  end

  def self.down
    change_column_default :spaces, :submission_type, 1
  end
end
