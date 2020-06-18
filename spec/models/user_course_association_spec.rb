# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserCourseAssociation do
  subject { FactoryBot.create(:user_course_association) }

  it { should belong_to :user }
  it { should belong_to :course }
  it { should have_many :logs }

  #FIXME Problema de tradução
  xit { should validate_uniqueness_of(:user_id).scoped_to(:course_id) }

  context "states" do
    [:approve!, :reject!, :fail!, :accept!, :deny!].each do |attr|
      it "responds to #{attr.to_s}" do
        should respond_to attr
      end
    end

    it "defaults to waiting" do
      subject.state.should == "waiting"
    end

    context "when waiting and the course is closed" do
      before do
        UserNotifier.delivery_method = :test
        UserNotifier.perform_deliveries = true
        UserNotifier.deliveries = []
      end

      it "should send a pending moderation request" do
        user = FactoryBot.create(:user)
        course = FactoryBot.create(:course, :subscription_type => 2, :owner => user)
        course.administrators.reload
        uca = FactoryBot.create(:user_course_association, :course => course)
        UserNotifier.deliveries.last.subject.should == "Moderação pendente em #{course.name}"
      end
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
        }.to change(subject, :state).to("invited")
      end

      it "should send mail" do
        subject.invite!
        UserNotifier.deliveries.last.subject.should =~ /Você foi convidado para realizar um curso a distância/
      end
    end

    context "when deny" do
      before do
        subject.invite!
      end

      it "should go to rejected" do
        expect {
          subject.deny!
        }.to change(subject, :state).to("rejected")
      end
    end

    context "when accept" do
      before do
        subject.invite!
      end

      it "should go to approved" do
        expect {
          subject.accept!
        }.to change(subject, :state).to("approved")
      end

      it "should create environment association" do
        expect {
          subject.accept!
        }.to change {
          subject.course.environment.user_environment_associations.count
        }.by(1)

        subject.course.environment.users.should include(subject.user)
      end

      it "should create hierachy associations" do
        subject.course.should_receive(:create_hierarchy_associations).with(subject.user, Role[:member])
        subject.accept!
      end

      context "when it is a new record" do
        before do
          @ass = FactoryBot.build(:user_course_association, :state => "invited")
        end

        it "should not call create hierarchy associations" do
          @ass.course.should_not_receive(:create_hierarchy_associations)
          @ass.accept!
        end
      end
    end

    context "when approving" do
      it "should create environment association" do
        expect {
          subject.approve!
        }.to change {
          subject.course.environment.user_environment_associations.count
        }.by(1)

        subject.course.environment.users.should include(subject.user)
      end

      it "should create hierachy associations" do
        subject.course.should_receive(:create_hierarchy_associations).with(subject.user, Role[:member])
        subject.approve!
      end

      context "when it is a new record" do
        let(:subject) { FactoryBot.build(:user_course_association) }

        it "should not call create hierarchy associations" do
          subject.course.should_not_receive(:create_hierarchy_associations)
          subject.approve!
        end
      end
    end
  end

  context "finder" do

    it "retrieves user course associations with specified roles" do
      assoc = (1..3).collect { FactoryBot.create(:user_course_association, :role => :tutor) }
      assoc2 = (1..3).collect { FactoryBot.create(:user_course_association, :role => :admin) }
      t = FactoryBot.create(:user_course_association, :role => :teacher)

      UserCourseAssociation.with_roles([ Role[:admin], Role[:teacher] ]).
        should == (assoc2 << t)
    end

    it "retrieves user course associations with specified keyword" do
      user = FactoryBot.create(:user, :first_name => "Andrew")
      assoc = FactoryBot.create(:user_course_association, :user => user)
      user2 = FactoryBot.create(:user, :first_name => "Joe Andrew")
      assoc2 = FactoryBot.create(:user_course_association, :user => user2)
      user3 = FactoryBot.create(:user, :first_name => "Alice")
      assoc3 = FactoryBot.create(:user_course_association, :user => user3)

      UserCourseAssociation.with_keyword("Andrew").
        should == [user.user_course_associations.last,
                   user2.user_course_associations.last]
    end

    it "retrieves new user_course_associations from 1 week ago" do
      @course = FactoryBot.create(:course)
      @uca = @course.user_course_associations.first

      user = FactoryBot.create(:user, :first_name => "Andrew")
      assoc = FactoryBot.create(:user_course_association, :user => user,
                      :course => @uca.course,
                      :created_at => 2.weeks.ago)
      user2 = FactoryBot.create(:user, :first_name => "Joe Andrew")
      assoc2 = FactoryBot.create(:user_course_association, :user => user2,
                       :course => @uca.course)
      user3 = FactoryBot.create(:user, :first_name => "Alice")
      assoc3 = FactoryBot.create(:user_course_association, :user => user3,
                       :course => @uca.course)

      @uca.course.user_course_associations.
        recent.should == [@uca, assoc2, assoc3]
    end

    it "retrieves approved user course associations" do
      course = FactoryBot.create(:course)
      uca = course.user_course_associations.first

      user = FactoryBot.create(:user, :first_name => "Andrew")
      assoc = FactoryBot.create(:user_course_association, :user => user,
                      :course => uca.course,
                      :created_at => 2.weeks.ago)
      assoc.approve!
      user2 = FactoryBot.create(:user, :first_name => "Joe Andrew")
      assoc2 = FactoryBot.create(:user_course_association, :user => user2,
                       :course => uca.course)
      assoc2.approve!
      user3 = FactoryBot.create(:user, :first_name => "Alice")
      assoc3 = FactoryBot.create(:user_course_association, :user => user3,
                       :course => uca.course)

      UserCourseAssociation.approved.should == [uca, assoc, assoc2]
    end

    it "retrieves invited user_course_associations" do
      course = FactoryBot.create(:course)
      @associations = (1..5).collect { course.invite(FactoryBot.create(:user)) }
      @associations[0..1].each { |a| a.accept! }
      @associations[2].deny!

      UserCourseAssociation.invited.should == @associations[3..4]
    end

    context "when retrieving last accessed" do
      let(:user) { FactoryBot.create(:user) }
      let(:assocs) do
        (1..5).collect { FactoryBot.create(:user_course_association, :user => user) }
      end

      it "retrieves 3 last accessed" do
        last_accessed = [0, 2, 4].collect do |i|
          assocs[i].touch(:last_accessed_at)
          assocs[i]
        end

        UserCourseAssociation.last_accessed(3).to_set.should ==
          last_accessed.to_set
      end

      it "retrieves empty if no courses where accessed" do
        assocs
        UserCourseAssociation.last_accessed(3).to_set.should ==
          Set.new
      end
    end
  end

  context "when notifying pending moderation" do
    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []

      @course = FactoryBot.create(:course)
      @ucas = 3.times.collect {
        FactoryBot.create(:user_course_association, :course => @course,
                :role => :environment_admin, :state => 'approved')
      }

      @new_uca = FactoryBot.create(:user_course_association, :course => @course, :role => :member)
    end

    it "should send email notifications" do
      expect {
        @new_uca.notify_pending_moderation
      }.to change(UserNotifier.deliveries, :count).by(4) # os 3 mais owner
    end

    it "should send email notifications with correct content" do
      @new_uca.notify_pending_moderation

      UserNotifier.deliveries.each do |message|
        message.text_part.to_s.should =~ /#{@new_uca.user.email}/
      end
    end
  end

  it_should_behave_like 'have unique index database'
end
