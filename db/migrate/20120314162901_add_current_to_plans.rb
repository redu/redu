# -*- encoding : utf-8 -*-
class AddCurrentToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :current, :boolean
    change_column_default :plans, :current, false

    add_index "plans", "current", :name => "index_plans_on_current"

    Plan.reset_column_information
    Plan.update_all :current => false
    # Marca como atual o último plano do billable
    Plan.select('id, created_at, billable_id, billable_type').all.
      group_by(&:billable).each do |billable, plans|
        ActiveRecord::Base.record_timestamps = false
        if billable
          plans_in_order = plans.sort { |x, y| x.created_at <=> y.created_at }
          current_plan = plans_in_order.last
          current_plan.update_attribute(:current, true)
        end # Caso o billable já tenha sido destruído, manter a coluna com false
    end && nil
  end

  def self.down
    remove_column :plans, :current
  end
end
