class UserSettingPolicyObserver < BasePolicyObserver
  observe :user_setting

  def after_create(setting)
    anyone_can_stalk(setting) if setting.view_mural?(:public)
  end

  def after_update(setting)
    return false unless setting.view_mural_changed?

    if setting.view_mural?(:public)
      anyone_can_stalk(setting)
    else
      async_policy_for(setting.user) do |policy|
        setting.user.friendships.accepted.each do |f|
          policy.add(:subject_id => "core:user_#{f.friend.id}", :action => :stalk)
        end
      end
    end
  end

  protected

  def anyone_can_stalk(setting)
    sync_policy_for(setting.user) do |policy|
      policy.add(:subject_id => "any", :action => :stalk)
    end
  end
end
