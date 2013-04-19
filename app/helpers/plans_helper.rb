module PlansHelper
  # define cor de texto de acordo com o status de pagamento do plano
  def plan_payment_status(plan)
    invoice = plan.invoice
    if plan.pending_payment?
      if invoice.try(:overdue?)
        'plan-status-overdue'
      else
        'plan-status-pending'
      end
    else
      if invoice.try(:closed?)
        'plan-status-closed'
      else
        'plan-status-no-pending'
      end
    end
  end
end
