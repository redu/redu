# -*- encoding : utf-8 -*-
class InvoicesController < BaseController
  respond_to :html, :js

  load_and_authorize_resource :plan, :except => :index
  load_and_authorize_resource :invoice, :through => [:plan], :except => :index

  def index
    @plan = load_and_authorize_if_param(Plan, params[:plan_id])
    @partner = load_and_authorize_if_param(Partner, params[:partner_id])

    # Conflita com o caso que não há @partner, se carregado pelo CanCan
    if client_id = params[:client_id]
      @client = @partner.partner_environment_associations.find(client_id)
    end

    if @plan
      @user = @plan.user
      @invoices = @plan.invoices
      @quota = @plan.billable.quota if @plan.billable
      # FIXME Planos dos parceiros não deveriam estar associados ao user.
      # A lógica abaixo foi adicionada pois planos de parceiros são listados
      # nos planos pessoais do usuário
      @partner = @plan.billable.partner if @plan.billable.is_a? Environment
      if @partner
        @client = @partner.partner_environment_associations.
          where(:environment_id => @plan.billable).first
      end
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
        format.html { render :layout => 'new_application' }
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

  protected

  def load_and_authorize_if_param(klass, id)
    if id
      instance = klass.find(id)
      authorize! :manage, instance
      instance
    end
  end
end
