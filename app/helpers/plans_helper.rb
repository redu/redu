# -*- encoding : utf-8 -*-
module PlansHelper
  # Define a classe (cor de texto) de acordo com o status de pagamento do plano.
  def plan_payment_status_class(plan)
    'plan-status-no-pending'
  end

  # Converte de bytes para megabytes.
  def bytes_to_mb(bytes)
    number_with_precision((bytes / 1.megabyte.to_f), :precision => 2)
  end
end
