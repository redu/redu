# -*- encoding : utf-8 -*-
class StatusUserAssociation < ActiveRecord::Base
  belongs_to :status
  belongs_to :user

  validates_uniqueness_of :status_id, :scope => :user_id
end
