# -*- encoding : utf-8 -*-
class PartnersController < BaseController
  load_and_authorize_resource

  def show
    @partner_environment_associations = \
      @partner.partner_environment_associations.page(params[:page]).
      per(Redu::Application.config.items_per_page)

    respond_to do |format|
      format.html { render :template => 'partner_environment_associations/index' }
    end

  end

  def index
    @partners = Partner.all
  end

  def contact
    @partner_contact = PartnerContact.new(params[:partner_contact])

    unless @partner_contact.migration
      @environment = Environment.new(params[:environment])
    end

    @partner_contact.deliver if @partner_contact.valid?

    respond_to do |format|
      format.js
    end
  end

  def success

  end
end
