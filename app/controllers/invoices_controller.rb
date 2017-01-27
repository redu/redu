# -*- encoding : utf-8 -*-
class InvoicesController < BaseController
  respond_to :html, :js

  load_and_authorize_resource :plan, :except => :index
  load_and_authorize_resource :invoice, :through => [:plan], :except => :index

  def index
    @plan = load_and_authorize_if_param(Plan, params[:plan_id])

    if @plan
      @user = @plan.user
      @invoices = @plan.invoices
      @quota = @plan.billable.quota if @plan.billable
    end

    @invoices = @invoices.pending if params.fetch(:pending, false)

    respond_to do |format|
        format.html { render :layout => 'new_application' }
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

  protected

  def load_and_authorize_if_param(klass, id)
    if id
      instance = klass.find(id)
      authorize! :manage, instance
      instance
    end
  end
end
