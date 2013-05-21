# -*- encoding : utf-8 -*-
require 'api_spec_helper'
require 'cancan/matchers'

describe "Course enrollment abilities" do
  subject { Api::Ability.new(@user) }
  before do
    @environment = FactoryGirl.create(:complete_environment)
    @course = @environment.courses.first
    @user = FactoryGirl.create(:user)
    @uca = @course.user_course_associations.first
  end

  context "when outsider" do
    it "should not be able to read" do
      subject.should_not be_able_to :read, @uca
    end
  end

  context "when administrator" do
    before { @user = @environment.owner }
    it "should be able to manage" do
      subject.should be_able_to :manage, @uca
    end
  end

  context "when member" do
    before { @course.join(@user) }
    it "should be able to destroy its own enrollment" do
      subject.should be_able_to :destroy, @user.get_association_with(@course)
    end
    it "should not be able to destroy others enrollments" do
      subject.should_not be_able_to :destroy, @uca
    end
  end

  context "when teacher" do
    before { @course.join(@user, Role[:teacher]) }
    it "should be able to destroy its own enrollment" do
      subject.should be_able_to :destroy, @user.get_association_with(@course)
    end
    it "should not be able to destroy others enrollments" do
      subject.should_not be_able_to :destroy, @uca
    end
  end

  context "when tutor" do
    before { @course.join(@user, Role[:tutor]) }
    it "should be able to destroy its own enrollment" do
      subject.should be_able_to :destroy, @user.get_association_with(@course)
    end
    it "should not be able to destroy others enrollments" do
      subject.should_not be_able_to :destroy, @uca
    end
  end
end
