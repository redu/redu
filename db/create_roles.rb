def create_roles
  Role.create(:name => 'admin', :space_role => false)
  Role.create(:name => 'member', :space_role => true)

  # Environment
  Role.create(:name => 'environment_admin', :space_role => false)

  # Course
  Role.create(:name => 'course_admin', :space_role => false)

  # Space
  Role.create(:name => 'teacher', :space_role => true)
  Role.create(:name => 'tutor', :space_role => true)
end
