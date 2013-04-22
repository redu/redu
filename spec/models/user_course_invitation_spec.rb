require 'spec_helper'

describe UserCourseInvitation do
  subject { Factory(:user_course_invitation) }

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
      subject.errors[:email].should_not be_empty
    end
  end

  context do
    before do
      @invites = (1..5).collect { Factory(:user_course_invitation) }
      @invites.each {|i| i.invite! }
    end

    it "retrieves invitations with state 'invited'" do
      @invites[0..2].each do |i|
        i.user = Factory(:user)
        i.accept!
      end
      UserCourseInvitation.invited.should == @invites[3..4]
    end

    it "retrieves invitations with given email" do
      email = "same@example.com"
      same_email_invites = (1..3).collect { Factory(:user_course_invitation,
                                                     :email => email) }

      UserCourseInvitation.with_email(email).should == same_email_invites
    end
  end

  context "states" do
    [:accept!, :deny!, :fail!].each do |attr|
      it "responds to #{attr}" do
        should respond_to attr
      end
    end

    it "defaults to waiting" do
      subject.state.should == "waiting"
    end

    context "when invited" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
        subject.invite!
      end

      it "sends an email" do
        subject.reload
        UserNotifier.deliveries.last.subject.should =~
          /Você foi convidado para realizar um curso a distância/
        UserNotifier.deliveries.last.body.should =~ /#{subject.course.name}/
      end
    end

    context "when accept" do
      before do
        subject.invite!
      end

      it "do NOT accept if it does not have a user" do
        expect {
          subject.accept!
        }.to raise_error(AASM::InvalidTransition)
      end

      it "creates a user course association with state 'invited'" do
        subject.user = Factory(:user)
        expect {
          subject.accept!
        }.to change(UserCourseAssociation, :count).by(1)
        assoc = UserCourseAssociation.last
        assoc.course.should == subject.course
        assoc.user.should == subject.user
        assoc.should be_invited
      end

      it "should destroy itself" do
        subject.user = Factory(:user)
        expect {
          subject.accept!
        }.to change(UserCourseInvitation, :count).by(-1)
      end
    end
  end
end
