require 'spec_helper'

describe 'FriendshipPolicyObserver' do
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

  context "when accepting friendship (UserSetting#view_miral is friends)" do
    let(:guila) do
      Factory(:user, :settings => \
              Factory(:user_setting, :view_mural => Privacy[:friends]))
    end
    let(:jubs) do
      Factory(:user, :settings => \
              Factory(:user_setting, :view_mural => Privacy[:friends]))
    end

    it "should give stalking permissions to both the user and the friend" do
      policy.should_receive(:add).
        with(:subject_id => "core:user_#{jubs.id}", :action => :stalk).once
      policy.should_receive(:add).
        with(:subject_id => "core:user_#{guila.id}", :action => :stalk).once

      active_observer do
        guila.be_friends_with(jubs)
        jubs.be_friends_with(guila)
      end
    end

    it "should not give any permissions when the friendship is pending" do
      policy.should_not_receive(:add)

      active_observer do
        jubs.be_friends_with(guila)
      end
    end
  end

  context "when accepting friendship (UserSettings#view_mura is public)" do
    let(:guila) do
      Factory(:user, :settings => \
              Factory(:user_setting, :view_mural => Privacy[:public]))
    end
    let(:jubs) do
      Factory(:user, :settings => \
              Factory(:user_setting, :view_mural => Privacy[:friends]))
    end

    it "should give stalking permissions just when needed" do
      policy.should_receive(:add).
        with(:subject_id => "core:user_#{guila.id}", :action => :stalk).once

      active_observer do
        guila.be_friends_with(jubs)
        jubs.be_friends_with(guila)
      end
    end
  end

  context "when destroying friendship" do
    let(:guila) { Factory(:user) }
    let(:jubs) { Factory(:user) }

    it "should remove the rules for both users" do
      guila.be_friends_with(jubs)
      jubs.be_friends_with(guila)

      policy.should_receive(:remove).
        with(:subject_id => "core:user_#{jubs.id}", :action => :stalk)
      policy.should_receive(:remove).
        with(:subject_id => "core:user_#{guila.id}", :action => :stalk)

      active_observer do
        guila.destroy_friendship_with(jubs)
      end
    end
  end

  def active_observer(&block)
    ActiveRecord::Observer.with_observers(:friendship_policy_observer) do
      block.call
    end
  end
end
