# -*- encoding : utf-8 -*-
class AddBillableAuditToPlan < ActiveRecord::Migration
  def self.up
    add_column :plans, :billable_audit, :text
  end

  def self.down
    remove_column :plans, :billable_audit
  end
end
