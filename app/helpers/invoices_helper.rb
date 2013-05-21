# -*- encoding : utf-8 -*-
module InvoicesHelper

  def total_amount_of(invoices)
    invoices.collect { |i| i.amount if i.amount }.compact.sum
  end

  def dates_of(invoices)
    invoices.group_by { |i| i.period_start.beginning_of_month }
  end
end
