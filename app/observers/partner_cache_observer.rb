class PartnerCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Partner

  def after_update(partner)
    expire_nav_account_for(partner.users)
  end
end
