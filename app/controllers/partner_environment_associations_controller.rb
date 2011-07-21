class PartnerEnvironmentAssociationsController < BaseController
  load_and_authorize_resource :partner
  load_and_authorize_resource :partner_environment_association,
    :through => :partner

  def create
    respond_to do |format|
      format.html do
        if @partner_environment_association.valid?
          redirect_to partner_environments_path(@partner)
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
    @partner_environment_association.build_environment
    respond_to do |format|
      format.html
    end
  end
end
