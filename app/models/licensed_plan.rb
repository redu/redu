class LicensedPlan < Plan

  def members_limit
    1.0/0 # Infinity
  end

  def create_invoice(opts = {})
    options = {
      :invoice => {
      :period_start => Date.today,
      :period_end => Date.today.end_of_month,
      :plan => self }
    }.deep_merge(opts)

    options[:invoice].delete(:amount) # Não deve aceitar amount nos parâmetros
    LicensedInvoice.create(options[:invoice])
  end
end
