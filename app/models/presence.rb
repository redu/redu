class Presence

  def self.list_of_channels(user)
    # All teachers and tutors
    users = user.user_course_associations.approved.includes(:course).
      collect do |uca|
        if uca.role.eql?(Role[:teacher]) || uca.role.eql?(Role[:tutor])
          uca.course.users
        else
          uca.course.teachers + uca.course.tutors
        end
      end
    # All friends
    users += user.friends
    users.flatten.uniq.collect do |friend|
      { :channel => "presence-user-#{friend.id}" }
    end
  end

  def self.fill_roles(user)
    roles = {}
    Role.select('DISTINCT name').each { |role| roles.merge!({role.name => false}) }
    user.user_course_associations.each do |uca|
      roles[Role[uca.role]] = true
    end
    roles
  end
end
