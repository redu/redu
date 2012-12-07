class PartnerCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Partner

  def after_update(partner)
    expire_nav_global_dropdown_menu_for(partner.users)
  end
end
