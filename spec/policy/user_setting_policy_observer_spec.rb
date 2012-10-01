require 'spec_helper'

describe 'UserSettingPolicyObserver' do
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

  context "when creating UserSetting with view_mural public" do
    let(:setting) do
      Factory(:user_setting).stub_chain(:user, :id).and_return(12)
    end

    it "should add stalk permission to anyone" do
      policy.should_receive(:add).with(:subject_id => "any", :action => :stalk)
      active_observer { setting }
    end
  end

  context "when creating UserSetting with view_mural friends" do
    let(:setting) do
      Factory(:user_setting, :view_mural => Privacy[:friends]).
        stub_chain(:user, :id).and_return(12)
    end

    it "should not add stalk permission to anyone" do
      policy.should_not_receive(:add)
      active_observer { setting }
    end
  end

  context "when updating UserSetting (friends to public)" do
    let(:setting) do
      s = Factory(:user_setting, :view_mural => Privacy[:friends])
      s.stub_chain(:user, :id).and_return(12)
      s
    end

    it "should add stalk permission to anyone" do
      setting

      policy.should_receive(:add).with(:subject_id => "any", :action => :stalk)
      active_observer { setting.update_attribute(:view_mural, Privacy[:public]) }
    end
  end

  context "when updating UserSetting (public to friends)" do
    let(:user) do
      some_guy = Factory(:user)
      2.times.collect { Factory(:user) }.each do |contact|
        some_guy.be_friends_with(contact)
        contact.be_friends_with(some_guy)
      end

      some_guy
    end
    let(:setting) { user.settings }

    it "should add stalk permission to his friends" do
      setting

      policy.should_receive(:add).with(hash_including(:action => :stalk)).twice
      active_observer { setting.update_attribute(:view_mural, Privacy[:friends]) }
    end
  end

  def active_observer(&block)
    ActiveRecord::Observer.
      with_observers(:user_setting_policy_observer) do
      block.call
    end
  end
end
