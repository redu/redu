class UserEnvironmentAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe UserEnvironmentAssociation

  def expire_sidebar_environments(uea)
    expire_sidebar_environments_for(uea.user)
  end

  alias_method :after_create, :expire_sidebar_environments
  alias_method :after_destroy, :expire_sidebar_environments
end
