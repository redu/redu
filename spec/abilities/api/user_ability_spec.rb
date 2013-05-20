# -*- encoding : utf-8 -*-
require "api_spec_helper"
require 'cancan/matchers'

describe Api::Ability do
  context "when user" do
    subject { Api::Ability.new(user) }
    let(:user) { Factory(:user) }

    it "should be able to manage itself" do
      subject.should be_able_to :manage, user
    end
  end

  context "when redu_admin" do
    subject { Api::Ability.new(user) }
    let(:user) { Factory(:user, :role => Role[:admin]) }
    it "should be able to manage all" do
      subject.should be_able_to :manage, :all
    end
  end

  context "when guest" do
    subject { Api::Ability.new(nil) }
    it "shold not be able read" do
      subject.should_not be_able_to :read, User
    end
  end
end
