class LecturePolicyObserver < BasePolicyObserver
  observe "lecture"

  def after_create(lecture)
    lecture.subject.enrollments.each do |e|
      sync_policy_for(lecture) do |policy|
        action = if e.role?(:teacher) || e.role?(:environment_admin)
                   {:action => :manage}
                 else
                   {:action => :read}
                 end
        policy.add({:subject_id => "core:user_#{e.user_id}"}.merge(action))
      end
    end
  end

  def after_destroy(lecture)
    lecture.subject.enrollments.each do |e|
      async_policy_for(lecture) do |policy|
        policy.remove(:subject_id => "core:user_#{e.user_id}")
      end
    end
  end

end
