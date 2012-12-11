class FriendshipCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Friendship

  def after_create(friendship)
    expire_friends_requisitions_for(friendship.user)
  end

  def after_update(friendship)
    if friendship.status_changed?
      expire_friends_requisitions_for(friendship.user)
    end
  end

  def after_destroy(friendship)
    expire_friends_requisitions_for(friendship.user)
  end
end
