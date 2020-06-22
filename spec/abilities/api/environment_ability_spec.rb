# -*- encoding : utf-8 -*-
require "api_spec_helper"
require 'cancan/matchers'

describe "Environment abilities" do
  context "when not a member" do
    subject { Api::Ability.new(@user) }
    before do
      @environment = FactoryBot.create(:complete_environment)
      @user = FactoryBot.create(:user)
      @application, @current_user, @token = generate_token(@user)
    end

    it "should not be able read" do
      subject.should_not be_able_to :read, @environment
    end

    it "should be able to create" do
      subject.should be_able_to :create, Environment
    end
  end

  context "when member" do
    subject { Api::Ability.new(@user) }
    before do
      @environment = FactoryBot.create(:complete_environment)
      @user = FactoryBot.create(:user)
      @environment.courses.first.join(@user)
      @application, @current_user, @token = generate_token(@user)
    end

    it "should be able to read" do
      subject.should be_able_to :read, @environment
    end

    it "should not be able manage" do
      subject.should_not be_able_to :manage, @environment
    end
  end

  context "when teacher" do
    subject { Api::Ability.new(@user) }
    before do
      @environment = FactoryBot.create(:complete_environment)
      @user = FactoryBot.create(:user)
      @environment.courses.first.join(@user, Role[:teacher])
      @application, @current_user, @token = generate_token(@user)
    end

    it "should be able to read" do
      subject.should be_able_to :read, @environment
    end

    it "should not be able manage" do
      subject.should_not be_able_to :manage, @environment
    end
  end

  context "when teacher" do
    subject { Api::Ability.new(@user) }
    before do
      @environment = FactoryBot.create(:complete_environment)
      @user = FactoryBot.create(:user)
      @environment.courses.first.join(@user, Role[:tutor])
      @application, @current_user, @token = generate_token(@user)
    end

    it "should be able to read" do
      subject.should be_able_to :read, @environment
    end

    it "should not be able manage" do
      subject.should_not be_able_to :manage, @environment
    end
  end

  context "when admin" do
    subject { Api::Ability.new(@user) }
    before do
      @environment = FactoryBot.create(:complete_environment)
      @user = @environment.owner
      @application, @current_user, @token = generate_token(@user)
    end

    it "should be able manage" do
      subject.should be_able_to :manage, @environment
    end
  end
end
