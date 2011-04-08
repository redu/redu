require 'spec_helper'

describe UserCourseInvitation do
  subject {Factory(:user_course_invitation)}

  it { should belong_to :course }
  it { should belong_to :user }

  # Problema de tradução
  [:token, :email, :course].each do |attr|
    it { should validate_presence_of attr }
  end
  xit { should validate_uniqueness_of :token }
  xit { should validate_uniqueness_of(:email).scoped_to(:course_id) }

  context "callbacks"  do
    it "generates token before validation on create" do
      i = Factory(:user_course_invitation, :token => nil)
      i.token.should_not be_nil
    end
  end

  context "validations" do
    it "validates email format" do
      subject.email = "invalid@inv"
      subject.should_not be_valid
      subject.errors.on(:email).should_not be_nil
    end
  end

  context "states" do
    [:accept!, :deny!, :fail!].each do |attr|
      it "responds to #{attr}" do
        should respond_to attr
      end
    end

    it "defaults to invited" do
      subject.current_state.should == :invited
    end

    context "when invited" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
      end

      it "sends an email" do
        subject.reload
        UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para um curso no Redu/
        UserNotifier.deliveries.last.body.should =~ /#{subject.course.name}/
      end
    end

    context "when accept" do
      it "do NOT accept if it does not have a user" do
        subject.accept!
        subject.should_not be_approved
      end

      it "creates a user course association with state 'invited'" do
        subject.user = Factory(:user)
        expect {
          subject.accept!
        }.should change(UserCourseAssociation, :count).by(1)
        assoc = UserCourseAssociation.last
        assoc.course.should == subject.course
        assoc.user.should == subject.user
        assoc.should be_invited
      end
    end
  end
end
