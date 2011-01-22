require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  context "redu admin" do
  end

  context "environment admin" do
  end

  context "teacher" do
  end

  context "tutor" do
  end
  context "on environment" do
    before do
      @env_admin = Factory(:user)
      @member = Factory(:user)
      @teacher = Factory(:user)
      @tutor = Factory(:user)
      @redu_admin = Factory(:user, :role => :admin)
      @environment = Factory(:environment, :owner => @env_admin)
      Factory(:user_environment_association, :environment => @environment,
              :user => @member, :role => :member)
    end
    context "member" do
      before do
        @ability = Ability.new(@member)
      end
      it "creates a environment" do
        env = Factory.build(:environment, :owner => @member)
        @ability.should be_able_to(:create, env)
      end
      it "destroys his own environment" do
        @ability.should be_able_to(:destroy, Factory.build(:environment, :owner => @member))
      end
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, Factory.build(:environment,
                                                               :owner => @member_out))
      end
    end
  end
end
