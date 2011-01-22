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
      xit "destroys his own environment" do
        @ability.should be_able_to(:destroy, Factory.build(:environment, :owner => @member))
      end
      it "cannot destroy a strange environment" do
        @ability.should_not be_able_to(:destroy, Factory.build(:environment,
                                                               :owner => @member_out))
      end
    end
  end

  context "on plan" do
    context "the member" do
      it "creates a plan" do
        anyone = Factory(:user)
        plan = Factory.build(:plan, :user => anyone)
        ability = Ability.new(anyone)

        ability.should be_able_to(:create, plan)
      end
    end

    context "the owner" do
      it "manages its own plan" do
        plan = Factory(:plan)
        ability = Ability.new(plan.user)

        ability.should be_able_to(:manage, plan)
      end
    end

    context "the strange" do
      it "cant read others plans" do
        strange = Factory(:user)
        plan = Factory(:plan)
        ability = Ability.new(strange)

        ability.should_not be_able_to(:read, plan)
      end
    end

  end
end
