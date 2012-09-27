require 'spec_helper'

describe 'UserSpaceAssociationPolicy' do
  let(:policy) { double('Permit::Policy') }
  let(:user) { Factory(:user) }
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

  %w(environment_admin teacher).each do |role|
    it "should add manage permission when #{role}" do
      policy.should_receive(:add).with(:subject_id=>"core:user_#{user.id}",
                                       :action => :manage)
      active_observer do
        Factory(:user_space_association, :user => user, :role => Role[role.to_sym])
      end
    end
  end

  %w(tutor member).each do |role|
    it "should add read permission when #{role}" do
      policy.should_receive(:add).with(:subject_id=>"core:user_#{user.id}",
                                       :action => :read)
      active_observer do
        Factory(:user_space_association, :user => user, :role => Role[role.to_sym])
      end
    end
  end

  %w(environment_admin teacher tutor member).each do |role|
    it "should remove the rule when role is #{role}" do
      policy.should_receive(:remove).with(:subject_id=>"core:user_#{user.id}")
      usa = Factory(:user_space_association, :user => user,
                    :role => Role[role.to_sym])

      active_observer { usa.destroy }
    end
  end

  def active_observer(&block)
    ActiveRecord::Observer.
      with_observers(:user_space_association_policy_observer) do
      block.call
    end
  end
end
