require 'spec_helper'
require 'support/permit_mock'

describe 'UserSpaceAssociationPolicy' do
  include Permit::TestCase

  let(:user) { Factory(:user) }
  before do
    policy.stub(:remove)
  end

  %w(environment_admin teacher).each do |role|
    it "should add manage permission when #{role}" do
      policy.stub(:add)
      space = Factory(:space)
      policy.should_receive(:add).with(:subject_id=>"core:user_#{user.id}",
                                       :action => :manage)
      active_observer do
        Factory(:user_space_association, :user => user,
                :space => space,
                :role => Role[role.to_sym])
      end
    end
  end

  %w(tutor member).each do |role|
    it "should add read permission when #{role}" do
      policy.stub(:add)
      space = Factory(:space)
      policy.should_receive(:add).with(:subject_id=>"core:user_#{user.id}",
                                       :action => :read)
      active_observer do
        Factory(:user_space_association, :user => user,
                :space => space,
                :role => Role[role.to_sym])
      end
    end
  end

  %w(environment_admin teacher tutor member).each do |role|
    it "should remove the rule when role is #{role}" do
      policy.stub(:remove)
      policy.stub(:add)

      usa = Factory(:user_space_association, :user => user,
                    :role => Role[role.to_sym])
      policy.should_receive(:remove).with(:subject_id=>"core:user_#{user.id}")

      active_observer { usa.destroy }
    end
  end

  # A criação dos USA para um Space em um Course previamente criado acontece
  # sem chamar os callbacks do Observer por questões de performance.
  # Nesse caso o observer é chamado manualmente.
  # (ver Space#create_space_association_for_users_course)
  context "when creating space" do
    let(:course) { Factory(:course, :owner => user, :environment => nil) }

    it "should add manage permission for course/space owner" do
      course.join(user, Role[:environment_admin])
      space = Factory.build(:space, :course => course,
                            :owner => course.owner)
      policy.should_receive(:add).
        with({:subject_id => "core:user_#{user.id}", :action => :manage})

      space.save
    end
  end

  context "when calling Course#create_hierarchy_associations" do
    it "should create policy for all spaces" do
      policy.stub(:add)
      user = Factory(:user)
      course = Factory(:complete_environment).courses.first

      policy.should_receive(:add).
        with(:subject_id => "core:user_#{user.id}", :action => :read)
      course.create_hierarchy_associations(user)
    end
  end

  def active_observer(&block)
    ActiveRecord::Observer.
      with_observers(:user_space_association_policy_observer) do
      block.call
    end
  end
end
