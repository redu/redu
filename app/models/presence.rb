class Presence

  def self.list_of_channels(user)
    user.friends.collect do |friend|
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
