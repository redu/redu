class PartnerUserAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe PartnerUserAssociation

  def expire_nav_global_dropdown_menu(pua)
    expire_nav_global_dropdown_menu_for(pua.user)
  end

  alias_method :after_create, :expire_nav_global_dropdown_menu
  alias_method :after_destroy, :expire_nav_global_dropdown_menu
end
