# -*- encoding : utf-8 -*-
class PaymentGatewayController < BaseController
  layout "application"

  skip_before_filter :verify_authenticity_token

  def callback
    redirect_to payment_success_path and return if request.get?

    pagseguro_notification do |notification|
      notification.products.each do |product|
        invoice = Invoice.find(product[:id])
        invoice.try(:pay!) if notification.status.eql?(:approved)
        invoice.audit ||= ""
        invoice.audit += "#{Time.zone.now}: #{notification.status} \n"
        invoice.audit += "#{notification.products.to_json} \n"
        invoice.audit += "#{notification.buyer.to_json} \n"
        invoice.save
      end
    end

    respond_to do |format|
      format.html do
        render :nothing => true
      end
    end
  end

  def success
  end

end
