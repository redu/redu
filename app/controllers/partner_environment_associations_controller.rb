class PartnerEnvironmentAssociationsController < BaseController
  load_and_authorize_resource :partner
  load_and_authorize_resource :partner_environment_association,
    :through => :partner

  def create
    respond_to do |format|
      format.html do
        if @partner_environment_association.valid?
          redirect_to partner_clients_path(@partner)
        else
          render :new
        end
      end
    end
  end

  def index
    respond_to do |format|
      format.html
    end
  end

  def new
    @partner_environment_association.build_environment
    respond_to do |format|
      format.html
    end
  end
end
