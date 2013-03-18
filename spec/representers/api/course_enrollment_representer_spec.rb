require 'spec_helper'

describe CourseEnrollmentRepresenter do
  context "UserCourseAssociation" do
    context "#role" do
      subject do
        Factory.build(:user_course_association).extend(CourseEnrollmentRepresenter)
      end

      %w(member teacher tutor environment_admin).each do |role|
        it "should represent #{role} role" do
          subject.update_attribute(:role, Role[role.to_sym])
          subject.to_hash.fetch("role").should == role
        end
      end
    end
  end
end
