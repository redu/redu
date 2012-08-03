class FriendshipCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Friendship

  def expire_sidebar_connections(friendship)
    expire_sidebar_connections_for(friendship.user)
  end

  def expire_friends_requisitions(friendship)
    expire_friends_requisitions_for(friendship.user)
  end

  def after_update(friendship)
    if friendship.status_changed?
      expire_friends_requisitions(friendship)

      if friendship.accepted?
        expire_sidebar_connections(friendship)
      end
    end
  end

  def after_destroy(friendship)
    expire_friends_requisitions(friendship)
    expire_sidebar_connections(friendship)
  end

  alias_method :after_create, :expire_friends_requisitions
end
