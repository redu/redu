class InvoicesController < BaseController
  load_and_authorize_resource :plan
  load_and_authorize_resource :invoice, :through => :plan

  def index
    @invoices = @plan.invoices
    @invoices = @invoices.pending if params.fetch(:pending, false)

    respond_to do |format|
      format.html
    end
  end

  def show

    respond_to do |format|
      format.html
    end
  end

end
