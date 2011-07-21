class PartnersController < BaseController
  load_and_authorize_resource

  def show
    pagitating = {
      :page => params[:page],
      :per_page => Redu::Application.config.items_per_page
    }

    @partner_environment_associations = \
      @partner.partner_environment_associations.paginate(pagitating)
    @users = @partner.users.paginate(pagitating)

    respond_to do |format|
      format.html { render :template => 'partner_environment_associations/index' }
    end

  end
end
