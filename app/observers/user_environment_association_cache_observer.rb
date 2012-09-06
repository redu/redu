class UserEnvironmentAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe UserEnvironmentAssociation

  def after_create(uea)
    expire_sidebar_environments_for(uea.user)
    expire_environment_sidebar_connections_with_count_for(uea.environment)
  end

  def after_destroy(uea)
    expire_sidebar_environments_for(uea.user)
    expire_environment_sidebar_connections_with_count_for(uea.environment)
  end
end
