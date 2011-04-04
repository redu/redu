require 'spec_helper'

describe UserCourseAssociation do
  subject { Factory(:user_course_association) }

  it { should belong_to :user }
  it { should belong_to :course }

  #FIXME Problema de tradução
  xit { should validate_uniqueness_of(:user_id).scoped_to(:course_id) }

  context "states" do
    [:approve!, :reject!, :fail!, :accept!, :deny!].each do |attr|
      it "responds to #{attr.to_s}" do
        should respond_to attr
      end
    end

    it "defaults to waiting" do
      subject.current_state.should == :waiting
    end

    context "when invite" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
      end

      it "should go to invited" do
        expect {
          subject.invite!
        }.should change(subject, :current_state).to(:invited)
      end

      it "should send mail" do
        subject.invite!
        UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para um curso no Redu/
        UserNotifier.deliveries.last.body.should =~ /#{subject.user.display_name}/
      end
    end

    context "when deny" do
      before do
        subject.invite!
      end

      it "should go to rejected" do
        expect {
          subject.deny!
        }.should change(subject, :current_state).to(:rejected)
      end
    end

    context "when accept" do
      before do
        subject.invite!
      end

      it "should go to approved" do
        expect {
          subject.accept!
        }.should change(subject, :current_state).to(:approved)
      end

      it "should create environment association" do
        expect {
          subject.accept!
        }.should change {
          subject.course.environment.user_environment_associations.count
        }.by(1)
      end

      it "should create hierachy associations" do
        subject.course.should_receive(:create_hierarchy_associations).with(subject.user)
        subject.accept!
      end
    end
  end

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
      @course = Factory(:course)
      @uca = @course.user_course_associations.first

      user = Factory(:user, :first_name => "Andrew")
      assoc = Factory(:user_course_association, :user => user,
                      :course => @uca.course,
                      :created_at => 2.weeks.ago)
      user2 = Factory(:user, :first_name => "Joe Andrew")
      assoc2 = Factory(:user_course_association, :user => user2,
                      :course => @uca.course)
      user3 = Factory(:user, :first_name => "Alice")
      assoc3 = Factory(:user_course_association, :user => user3,
                      :course => @uca.course)

      @uca.course.user_course_associations.
        recent.should == [@uca, assoc2, assoc3]
    end

    it "retrieves approved user course associations"do
      course = Factory(:course)
      uca = course.user_course_associations.first

      user = Factory(:user, :first_name => "Andrew")
      assoc = Factory(:user_course_association, :user => user,
                      :course => uca.course,
                      :created_at => 2.weeks.ago)
      assoc.approve!
      user2 = Factory(:user, :first_name => "Joe Andrew")
      assoc2 = Factory(:user_course_association, :user => user2,
                      :course => uca.course)
      assoc2.approve!
      user3 = Factory(:user, :first_name => "Alice")
      assoc3 = Factory(:user_course_association, :user => user3,
                      :course => uca.course)

      UserCourseAssociation.approved.should == [uca, assoc, assoc2]
    end
  end

  context "when there are invitations (state is invted)" do
    before do
      subject.invite!
    end
  
    it "should return true" do
      UserCourseAssociation.has_invitation_for?(subject.user).should be_true
    end
  end
end
