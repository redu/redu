class PartnersController < BaseController
  load_and_authorize_resource

  def show
    pagitating = {
      :page => params[:page],
      :per_page => Redu::Application.config.items_per_page
    }

    @partner_environment_associations = \
      @partner.partner_environment_associations.paginate(pagitating)

    respond_to do |format|
      format.html { render :template => 'partner_environment_associations/index' }
    end

  end

  def contact
    @environment = Environment.new(params[:environment])
    @partner_contact = PartnerContact.new(params[:partner_contact])

    @partner_contact.deliver if @partner_contact.valid?

    respond_to do |format|
      format.js
    end
  end

  def success

  end
end
