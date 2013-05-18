class PartnerUserAssociationsController < BaseController
  load_and_authorize_resource :partner

  def index
    @partner_user_associations = \
      @partner.partner_user_associations.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html
      format.js
    end
  end
end
