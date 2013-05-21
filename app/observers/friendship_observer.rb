# -*- encoding : utf-8 -*-
class FriendshipObserver < ActiveRecord::Observer
  def after_update(friendship)
    Log.setup(friendship, :action => :update)
  end

  def after_create(friendship)
    friendship.notify_request
  end
end
