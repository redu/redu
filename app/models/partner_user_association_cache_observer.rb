class PartnerUserAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe PartnerUserAssociation

  def expire_nav_account(pua)
    expire_nav_account_for(pua.user)
  end

  alias_method :after_create, :expire_nav_account
  alias_method :after_destroy, :expire_nav_account
end
