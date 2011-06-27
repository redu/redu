class Presence

  def self.list_of_channels(user)
    self.list_of_contacts(user).uniq.collect do |friend|
      { :pre_channel => friend.presence_channel,
        :pri_channel => user.private_channel_with(friend) }
    end
  end

  def self.fill_roles(user)
    roles = {}
    Role.select('DISTINCT name').each { |role| roles.merge!({role.name => false}) }
    user.user_course_associations.each do |uca|
      roles[Role[uca.role]] = true
    end
    roles["admin"] = true if user.admin?
    roles
  end

  def self.list_of_contacts(user)
    # All teachers and tutors
    users = user.user_course_associations.approved.includes(:course).
      collect do |uca|
      if uca.role.eql?(Role[:teacher]) || uca.role.eql?(Role[:tutor])
        uca.course.users
      else
        uca.course.teachers_and_tutors
      end
      end
    # All friends
    users += user.friends
    users.flatten!
    users.delete(user)
    users
  end
end
