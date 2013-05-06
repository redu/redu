module PlansHelper
  # Define a classe (cor de texto) de acordo com o status de pagamento do plano.
  def plan_payment_status_class(plan)
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

  # Converte de bytes para megabytes.
  def bytes_to_mb(bytes)
    number_with_precision((bytes / 1.megabyte.to_f), :precision => 2)
  end
end
