require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe SpacesController do
  context "GET students_endless" do
    before do
      environment = Factory(:environment, :published => true)
      course = Factory(:course, :environment => environment)
      space = Factory(:space, :course => course)
      user = Factory(:user)
      space.course.join user
      activate_authlogic
      UserSession.create user

      get :students_endless, :id => space.id, :locale => "pt-BR",
        :format => "js"
    end

    it "should be_success" do
      response.should be_success
    end

    it "assigns @sidebar_students" do
      assigns[:sidebar_students].should_not be_nil
    end
  end

  context "GET users" do
    before do
      course = Factory(:course)
      space = Factory(:space, :course => course)
      user = Factory(:user)
      course.join user
      activate_authlogic
      UserSession.create user

      get :users, :id => space.id, :locale => "pt-BR"
    end

    [:users, :teachers, :tutors, :students].each do |v|
      it "assigns #{v}" do
        assigns[v].should_not be_nil
      end
    end
  end
end
