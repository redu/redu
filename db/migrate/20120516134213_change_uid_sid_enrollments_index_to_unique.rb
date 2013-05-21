# -*- encoding : utf-8 -*-
class ChangeUidSidEnrollmentsIndexToUnique < ActiveRecord::Migration
  def self.up
    remove_index :enrollments, :name => "idx_enrollments_u_id_and_sid"
    add_index :enrollments, [:user_id, :subject_id], :unique => true,
      :name => "idx_enrollments_u_id_and_sid"
  end

  def self.down
    remove_index :enrollments, :name => "idx_enrollments_u_id_and_sid"
    add_index :enrollments, [:user_id, :subject_id],
      :name => "idx_enrollments_u_id_and_sid"
  end
end
