class UserCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe User

  def after_update(user)
    if user.first_name_changed? || user.last_name_changed? ||
      user.login_changed?
      future_friends = user.friendships.requested.includes(:friend).
        collect(&:friend)

      expire_friends_requisitions_for(future_friends)
      expire_nav_global_dropdown_menu_for(user)
    end
  end
end
