class UserSpaceAssociationPolicyObserver < BasePolicyObserver
  observe :user_space_association

  def after_create(usa)
    sync_policy_for(usa.space) do |policy|
      if usa.role?(:environment_admin) || usa.role?(:teacher)
        policy.add(:subject_id => "core:user_#{usa.user.id}", :action => :manage)
      else
        policy.add(:subject_id => "core:user_#{usa.user.id}", :action => :read)
      end
    end
  end

  def after_destroy(usa)
    async_policy_for(usa.space) do |policy|
      policy.remove(:subject_id => "core:user_#{usa.user.id}")
    end
  end
end
