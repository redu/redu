require 'spec_helper'

describe 'EnrollmentPolicyObserver' do
  let(:policy) { double('Permit::Policy') }
  before do
    @@policy = policy # necessário para ser visível abaixo
    class BasePolicyObserver < ActiveRecord::Observer
      def sync_policy_for(model, &block)
        block.call @@policy
      end

      def async_policy_for(model, &block)
        block.call @@policy
      end
    end

    class Permit::PolicyJob
      def perform
        @callback.call(@@policy)
      end
    end
  end

  context "when creating enrollment with callbacks enabled" do
    let(:user) { Factory(:user) }
    let(:subject) do
      s = Factory(:subject, :space => nil)
      s.lectures << Factory(:lecture, :subject => s)
      s
    end

    %w(teacher environment_admin).each do |role|
      it "should add manage rights to lecture with #{role}" do
        policy.should_receive(:add).
          with(:subject_id => "core:user_#{user.id}", :action => :manage)

        active_observer do
          Factory(:enrollment, :user => user, :subject => subject,
                  :role => Role[role.to_sym])
        end
      end
    end

    %w(member tutor).each do |role|
      it "should add read rights to lecture with #{role}" do
        policy.should_receive(:add).
          with(:subject_id => "core:user_#{user.id}", :action => :read)

        active_observer do
          Factory(:enrollment, :user => user, :subject => subject,
                  :role => Role[role.to_sym])
        end
      end
    end
  end

  context "when calling Subject.enroll" do
    let(:user) { Factory(:user) }
    before do
      @subject = Factory(:subject, :space => nil)
      @subject.lectures << Factory(:lecture, :subject => @subject)
    end

    %w(member tutor).each do |role|
      it "should add read rights to lecture with #{role}" do
        policy.should_receive(:add).
          with(:subject_id => "core:user_#{user.id}", :action => :read)

        active_observer do
          Subject.enroll(user, [@subject], Role[role.to_sym])
        end
      end
    end

    %w(teacher environment_admin).each do |role|
      it "should add manage rights to lecture with #{role}" do
        policy.should_receive(:add).
          with(:subject_id => "core:user_#{user.id}", :action => :manage)

        active_observer do
          Subject.enroll(user, [@subject], Role[role.to_sym])
        end
      end
    end
  end

  context "when destroying the Enrollment" do
    let(:user) { Factory(:user) }
    let(:enrollment) do
      Factory(:enrollment,
              :subject => Factory(:subject, :space => nil, :owner => user))
    end


    it "should remove the rule" do
      Factory(:lecture, :subject => enrollment.subject, :owner => user)
      enrollment.subject.lectures.reload

      policy.should_receive(:remove).
        with(:subject_id => "core:user_#{enrollment.user.id}")

      active_observer do
        enrollment.destroy
      end
    end
  end

  context "when destroying the Subject" do
    let(:user) { Factory(:user) }
    let(:subject) do
      Factory(:subject, :space => nil, :owner => user)
    end

    it "should remove the rules for all Lectures" do
      2.times { Factory(:lecture, :subject => subject, :owner => user) }
      subject.lectures.reload
      2.times { subject.enroll(Factory(:user)) }
      subject.enroll(user) # SubjectObserver não está habilitado

      policy.should_receive(:remove).exactly(6)

      active_observer do
        subject.destroy
      end
    end



  end

  context "when creating subject" do
    let(:subj) do
      space = Factory(:complete_environment).courses.first.spaces.first
      s = Factory(:subject, :space => space, :owner => space.owner)
    end

    it "should not add policy for lecture when the subject is empty" do
      policy.should_receive(:add).once # user_space_association

      active_observer { subj }
    end
  end

  def active_observer(obs=:enrollment_policy_observer, &block)
    ActiveRecord::Observer.with_observers(*obs) do
      block.call
    end
  end
end
