class FriendshipObserver < ActiveRecord::Observer
  def after_update(friendship)
    Log.setup(friendship, :action => :update)
  end
end
