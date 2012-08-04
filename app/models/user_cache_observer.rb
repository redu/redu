class UserCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe User

  def after_update(user)
    future_friends = user.friendships.requested.includes(:friend).
      collect(&:friend)

    expire_friends_requisitions_for(future_friends)
    expire_nav_account_for(user)
  end
end
