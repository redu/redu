require 'spec_helper'

describe 'LecturePolicyObserver' do
  let(:policy) { double('Permit::Policy') }
  before do
    @@policy = policy # necessário para ser visível abaixo
    class BasePolicyObserver < ActiveRecord::Observer
      def sync_policy_for(model, &block)
        block.call @@policy
      end
    end

    class Permit::PolicyJob
      def perform
        @callback.call(@@policy)
      end
    end
  end

  context "when creating lecture" do
    let(:subject) { Factory(:subject, :space => nil) }
    let(:lecture) do
      Factory(:lecture, :subject => subject, :owner => subject.owner)
    end

    it "should add permission to all enrolled users" do
      3.times { |i| subject.enroll(Factory(:user)) }

      policy.should_receive(:add).exactly(3).times
      active_observer { lecture }
    end

    %w(teacher environment_admin).each do |role|
      it "should add manage permission to #{role}" do
        user = Factory(:user)
        subject.enroll(user, Role[role.to_sym])

        policy.should_receive(:add).
          with(:subject_id => "core:user_#{user.id}", :action => :manage)
        active_observer { lecture }
      end
    end

    %w(member tutor).each do |role|
      it "should add read permission to #{role}" do
        user = Factory(:user)
        subject.enroll(user, Role[role.to_sym])

        policy.should_receive(:add).
          with(:subject_id => "core:user_#{user.id}", :action => :read)
        active_observer { lecture }
      end
    end
  end

  context "when destroying lecture" do
    let(:subject) { Factory(:subject, :space => nil) }
    let(:lecture) do
      Factory(:lecture, :subject => subject, :owner => subject.owner)
    end
    before { lecture }

    it "should remove permission to all enrolled users" do
      3.times { |i| subject.enroll(Factory(:user)) }

      policy.should_receive(:remove).exactly(3).times
      active_observer { lecture.destroy }
    end
  end

  def active_observer(&block)
    ActiveRecord::Observer.with_observers(:lecture_policy_observer) do
      block.call
    end
  end
end
