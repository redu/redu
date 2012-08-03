class UserCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe User

  def expire_friends_requisitions(user)
    future_friends = user.friendships.requested.includes(:friend).
      collect do |friendship|
        friendship.friend
      end

      expire_friends_requisitions_for(future_friends)
  end

  alias_method :after_update, :expire_friends_requisitions
end
