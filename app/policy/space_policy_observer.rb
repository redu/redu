class SpacePolicyObserver < BasePolicyObserver
  observe :space

  def after_create(space)
    delay_policy_creation(space) do |policy|
      members(space).each do |subject|
        policy.add(:subject_id => subject, :action => :read)
      end
      tutors(space).each do |subject|
        policy.add(:subject_id => subject, :action => :read)
      end
      teachers(space).each do |subject|
        policy.add(:subject_id => subject, :action => :manage)
      end
      administrators(space).each do |subject|
        policy.add(:subject_id => subject, :action => :manage)
      end
    end
  end

  protected

  def teachers(space)
    members(space, 'teachers')
  end

  def tutors(space)
    members(space, 'tutors')
  end

  def administratos(space)
    members(space, 'tutors')
  end

  def members(space, role='students')
    space.course.send(role).find(:all, :select => "users.id").collect do |user|
      permit_id(user)
    end
  end
end
