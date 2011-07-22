class PartnerUserAssociationsController < BaseController
  load_and_authorize_resource :partner

  def index
    paginating = {
      :page => params[:page],
      :per_page => Redu::Application.config.items_per_page
    }

    @partner_environment_associations = \
      @partner.partner_environment_associations.paginate(paginating)
    @partner_user_associations = \
      @partner.partner_user_associations.paginate(paginating)

    respond_to do |format|
      format.html { render :template => 'partner_environment_associations/index' }
      format.js
    end
  end
end
