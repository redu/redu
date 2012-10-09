class EnrollmentPolicyObserver < BasePolicyObserver
  observe "enrollment"

  def after_create(enrollment)
    enrollment.subject.lectures.each do |lecture|
      sync_policy_for(lecture) do |policy|
        if enrollment.role?(:environment_admin) || enrollment.role?(:teacher)
          action = { :action => :manage }
        else
          action = { :action => :read }
        end
        policy.
          add({:subject_id => "core:user_#{enrollment.user_id}"}.merge(action))
      end
    end
  end

  def after_destroy(enrollment)
    enrollment.subject.lectures.each do |lecture|
      async_policy_for(lecture) do |policy|
        policy.remove(:subject_id => permit_id(enrollment.user))
      end
    end
  end
end
