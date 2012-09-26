require 'spec_helper'

describe 'UserPolicyObserver' do
  let(:policy) { double('Permit::Policy') }
  before do
    @@policy = policy # necessário para ser visível abaixo
    class BasePolicyObserver < ActiveRecord::Observer
      def sync_create_policy_for(model, &block)
        block.call @@policy
      end
    end

    class Permit::PolicyJob
      def perform
        @callback.call(@@policy)
      end
    end
  end

  it "should give manage permissions for the user itself" do
    policy.should_receive(:add)
    active_observer do
      Factory(:user)
    end
  end

  it "should remove permissions for the user itself" do
    @user = Factory(:user)
    policy.should_receive(:remove).with(:subject_id => "core:user_#{@user.id}")
    active_observer do
      @user.destroy
    end
  end

  def active_observer(&block)
    ActiveRecord::Observer.with_observers(:user_policy_observer) do
      block.call
    end
  end
end
