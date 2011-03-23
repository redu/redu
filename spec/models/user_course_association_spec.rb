require 'spec_helper'

describe UserCourseAssociation do
  before do
    @course = Factory(:course)
  end
  subject { @course.user_course_associations.first }

  it { should belong_to :user }
  it { should belong_to :course }

  #FIXME Problema de tradução
  xit { should validate_uniqueness_of(:user_id).scoped_to(:course_id) }

  context "finder" do

    it "retrieves user course associations with specified roles" do
      assoc = (1..3).collect { Factory(:user_course_association, :role => :tutor) }
      assoc2 = (1..3).collect { Factory(:user_course_association, :role => :admin) }
      t = Factory(:user_course_association, :role => :teacher)

      UserCourseAssociation.with_roles([ Role[:admin].id, Role[:teacher].id ]).
        should == (assoc2 << t)
    end

    it "retrieves user course associations with specified keyword" do
      user = Factory(:user, :first_name => "Andrew")
      assoc = Factory(:user_course_association, :user => user)
      user2 = Factory(:user, :first_name => "Joe Andrew")
      assoc2 = Factory(:user_course_association, :user => user2)
      user3 = Factory(:user, :first_name => "Alice")
      assoc3 = Factory(:user_course_association, :user => user3)

      UserCourseAssociation.with_keyword("Andrew").
        should == [user.user_course_associations.last,
          user2.user_course_associations.last]
    end

    it "retrieves new user_course_associations from 1 week ago" do
      user = Factory(:user, :first_name => "Andrew")
      assoc = Factory(:user_course_association, :user => user,
                      :course => subject.course,
                      :created_at => 2.weeks.ago)
      user2 = Factory(:user, :first_name => "Joe Andrew")
      assoc2 = Factory(:user_course_association, :user => user2,
                      :course => subject.course)
      user3 = Factory(:user, :first_name => "Alice")
      assoc3 = Factory(:user_course_association, :user => user3,
                      :course => subject.course)

      subject.course.user_course_associations.
        recent.should == [subject, assoc2, assoc3]
    end
  end
end
