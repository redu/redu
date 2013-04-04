class UserEnvironmentAssociationCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe UserEnvironmentAssociation

  def after_create(uea)
    if uea.role == Role[:environment_admin]
      expire_search_environment_administrators_for(uea.environment)
    end

    expire_environment_sidebar_connections_with_count_for(uea.environment)
  end

  def after_update(uea)
    if uea.role_changed?
      expire_search_environment_administrators_for(uea.environment)
    end
  end

  def after_destroy(uea)
    if uea.role == Role[:environment_admin]
      expire_search_environment_administrators_for(uea.environment)
    end

    expire_environment_sidebar_connections_with_count_for(uea.environment)
  end
end
