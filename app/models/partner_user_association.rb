# -*- encoding : utf-8 -*-
class PartnerUserAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :partner
end
