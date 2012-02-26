class PartnerEnvironmentAssociationsController < BaseController
  load_and_authorize_resource :partner
  load_and_authorize_resource :partner_environment_association,
    :through => :partner

  def create
    @partner_environment_association.environment.owner = current_user

    paginating = {
      :page => params[:page],
      :per_page =>Redu::Application.config.items_per_page
    }

    @partner_user_associations = \
      @partner.partner_user_associations.paginate(paginating)

    respond_to do |format|
      format.html do
        if @partner_environment_association.save
          plan_type, key = params[:plan].split("-")
          @plan = Plan.from_preset(key.to_sym, plan_type.classify)
          @plan.user = current_user
          @partner_environment_association.environment.create_quota
          @partner_environment_association.environment.plans << @plan
          @plan.create_invoice_and_setup

          admins = @partner.users.reject { |u| u.eql?(current_user) }
          admins.each { |u| @partner.join_hierarchy(u) }
          redirect_to partner_path(@partner)
        else
          render :new
        end
      end
    end
  end

  def index
    paginating = {
      :page => params[:page],
      :per_page =>Redu::Application.config.items_per_page
    }

    @partner_environment_associations = \
      @partner.partner_environment_associations.paginate(paginating)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    paginating = {
      :page => params[:page],
      :per_page =>Redu::Application.config.items_per_page
    }

    @partner_environment_association.build_environment

    respond_to do |format|
      format.html
    end
  end
end
