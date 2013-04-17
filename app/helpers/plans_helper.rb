module PlansHelper
  def plan_payment_status(plan)
    invoice = plan.invoice
    if plan.pending_payment?
      if invoice.overdue?
        'overdue'
      else
        'pending'
      end
    else
      if invoice.closed?
        'closed'
      else
        'no-pending'
      end
    end
  end
end
