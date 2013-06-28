# Identifica os spaces que tem a contagem diferente do course
incorrect_spaces = []
Space.where(published: true, destroy_soon: false).find_each do |space|
  if space.users.count != space.course.approved_users.count
    incorrect_spaces << space.id
  end
end

# Script que resolve as inconsistência de quantidade de membros 
# entre space e course
incorrect_spaces.each do |isp|
  space = Space.find(isp)

  space_members = space.users.map(&:id)
  course_members = space.course.approved_users.map(&:id)

  if space_members.size > course_members.size
    complement_members_space = space_members.reject { |t| course_members.include?(t) }
    complement_members_space.each do |cms|
      space.course.unjoin(User.find(cms))
    end
  else
    complement_members_course = course_members.reject { |t| space_members.include?(t) }
    complement_members_course.each do |cmc|
      uca = UserCourseAssociation.where(course_id: space.course.id, user_id: cmc).first
      space.course.create_hierarchy_associations(uca.user, uca.role)
    end
  end
end

# Identifica inconsistâncias de quantidade de membros entre subject e space
incorrect_subjects = []
Subject.where(finalized: true).find_each do |subject|
  if subject.members.count != subject.space.users.count
    incorrect_subjects << subject.id
  end
end

# Script que resolve o problema de inconsistências de quantidade de membros entre 
# subject e space
incorrect_subjects.each do |is|
  sub = Subject.find(is)

  sub_members = sub.members.map(&:id)
  space_members = sub.space.users.map(&:id)

  if space_members.size < sub_members.size
    rejected_members = sub_members.reject{ |t| space_members.include?(t) }

    Subject.unenroll(sub, rejected_members)
  else
    rejected_members = space_members.reject{ |t| sub_members.include?(t) }

    rejected_members.each do |rm|
      usa = UserSpaceAssociation.where(space_id: sub.space.id, user_id: rm).first
      Subject.enroll(sub, {users: usa.user, role: usa.role})
    end
  end
end
