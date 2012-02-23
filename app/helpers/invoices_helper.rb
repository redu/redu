module InvoicesHelper

  def total_amount
    @invoices.collect { |i| i.amount if i.amount }.compact.sum
  end
end
