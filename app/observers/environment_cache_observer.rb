class EnvironmentCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Environment

  def after_update(environment)
    expire_sidebar_environments_for(environment.users)
  end
end
