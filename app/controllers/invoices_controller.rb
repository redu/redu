class InvoicesController < BaseController
  load_and_authorize_resource :plan
  load_and_authorize_resource :invoice, :through => :plan

  def index
    @user = @plan.user
    @invoices = @plan.invoices
    @invoices = @invoices.pending if params.fetch(:pending, false)
    @quota = @plan.billable.quota if @plan.billable.quota

    respond_to do |format|
      format.html do
        render :template => "invoices/new/index", :layout => "new/application"
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

end
