class EnvironmentCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Environment

  def expire_sidebar_environments(environment)
    expire_sidebar_environments_for(environment.users)
  end

  alias_method :after_update, :expire_sidebar_environments
end
