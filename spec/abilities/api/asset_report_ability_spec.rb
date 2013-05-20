# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "AssetReport Ability" do
  let(:user) { Factory(:user) }
  subject { Api::Ability.new(user) }

  context "when not related to the asset report" do
    let(:asset_report) { Factory(:asset_report) }

    it "should not be able to manage" do
      subject.should_not be_able_to :manage, asset_report
    end

    it "should not be able to read" do
      subject.should_not be_able_to :read, asset_report
    end
  end

  context "when related to the asset report" do
    let(:enrollment) { Factory(:enrollment, :user => user) }
    let(:asset_report) { Factory(:asset_report, :enrollment => enrollment) }

    it "should be able to manage" do
      subject.should be_able_to :manage, asset_report
    end

    it "should be able to read" do
      subject.should be_able_to :read, asset_report
    end
  end
end
