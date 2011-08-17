class UserObserver < ActiveRecord::Observer
  def after_update(user)
    Log.setup(user, :action => :update)
  end
end
