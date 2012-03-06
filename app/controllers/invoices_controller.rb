class InvoicesController < BaseController
  respond_to :html, :js

  load_and_authorize_resource :plan
  load_and_authorize_resource :invoice, :through => [:plan], :except => :index
  load_and_authorize_resource :partner, :only => :index

  def index
    # Conflita com o caso que não há @partner, se carregado pelo CanCan
    if params[:client_id]
      @client = @partner.partner_environment_associations.find(params[:client_id])
    end

    if @plan
      @invoices = @plan.invoices
      @quota = @plan.billable.quota if @plan.billable
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
      if @client
        format.html { render "partner_environment_associations/invoices/index" }
      elsif @partner
        format.html { render "partners/invoices/index" } if @reference_period
        format.html { render "partners/invoices/monthly" }
      else
        format.html
      end
    end
  end

  def show
  end

  def pay
    @invoice.pay!

    respond_with do |format|
      format.html { redirect_to plan_invoices_path(@invoice.plan) }
    end
  end
end
