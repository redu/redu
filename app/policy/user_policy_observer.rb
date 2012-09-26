class UserPolicyObserver < BasePolicyObserver
  observe :user

  def after_create(user)
    sync_create_policy_for(user) do |policy|
      policy.add(:subject_id => "core:user_#{user.id}", :action => :manage)
    end
  end

  def after_destroy(user)
    async_create_policy_for(user) do |policy|
      policy.remove(:subject_id => "core:user_#{user.id}")
    end
  end
end
