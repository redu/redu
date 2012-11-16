class FriendshipPolicyObserver < BasePolicyObserver
  observe "friendship"

  def after_update(friendship)
    user, friend = friendship.user, friendship.friend

    if accepting_friendship?(friendship) && user.settings.view_mural?(:friends)
      async_policy_for(user) do |policy|
        policy.add(:subject_id => permit_id(friend), :action => :stalk)
      end
    end
  end

  def after_destroy(friendship)
    async_policy_for(friendship.user) do |policy|
      policy.remove(:subject_id => permit_id(friendship.friend), :action => :stalk)
    end
  end

  protected

  # Retorna true apenas quando o friendship está sendo aceito
  def accepting_friendship?(friendship)
    friendship.status_changed? && friendship.accepted?
  end
end
