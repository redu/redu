class EnvironmentCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Environment

  def after_update(environment)
    expire_sidebar_environments_for(environment.users.find(:all, :select => "users.id"))
  end
end
