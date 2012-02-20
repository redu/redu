class InvoicesController < BaseController
  load_and_authorize_resource :plan
  load_and_authorize_resource :partner, :only => :index
  load_and_authorize_resource :invoice, :through => [:plan], :except => :index

  def index
    if @plan
      @invoices = @plan.invoices
      @quota = @plan.billable.quota if @plan.billable.quota
    elsif @partner
      @invoices = @partner.invoices
      if params.fetch(:year, false)
        @reference_period = if params.fetch(:month, false)
                             reference_date = Date.new(params[:year].to_i,
                                                       params[:month].to_i)
                             reference_date..reference_date.end_of_month
                           else
                             reference_date = Date.new(params[:year].to_i)
                             reference_date..reference_date.end_of_year
                           end
        @invoices = @invoices.of_period(@reference_period)
      end
    end
    @invoices = @invoices.pending if params.fetch(:pending, false)

    respond_to do |format|
      format.html { render "partners/invoices/index" } if @partner
      format.html
    end
  end

  def show
  end
end
